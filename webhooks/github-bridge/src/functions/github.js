const { app } = require('@azure/functions');
const crypto = require('crypto');

/**
 * GitHub Webhook Bridge for Clawdbot
 * 
 * Receives GitHub webhooks, validates signature, transforms payload,
 * and forwards to Clawdbot /hooks/agent endpoint.
 */

// Verify GitHub webhook signature
function verifySignature(payload, signature, secret) {
    if (!signature || !secret) return false;
    
    const sig = signature.replace('sha256=', '');
    const hmac = crypto.createHmac('sha256', secret);
    const digest = hmac.update(payload).digest('hex');
    
    try {
        return crypto.timingSafeEqual(Buffer.from(sig), Buffer.from(digest));
    } catch {
        return false;
    }
}

// Transform GitHub event to Clawdbot message
function transformEvent(event, payload) {
    const repo = payload.repository?.full_name || 'unknown/repo';
    const sender = payload.sender?.login || 'unknown';
    
    switch (event) {
        case 'issues': {
            const issue = payload.issue;
            const action = payload.action;
            
            if (action === 'opened') {
                return {
                    message: `[GitHub] New issue #${issue.number} in ${repo}: ${issue.title}\n\nBy: ${sender}\n\n${issue.body || '(no description)'}`,
                    sessionKey: `github:${repo}:issue:${issue.number}`,
                    priority: 'normal'
                };
            } else if (action === 'closed') {
                return {
                    message: `[GitHub] Issue #${issue.number} closed in ${repo}: ${issue.title}\n\nClosed by: ${sender}`,
                    sessionKey: `github:${repo}:issue:${issue.number}`,
                    priority: 'low'
                };
            }
            break;
        }
        
        case 'issue_comment': {
            const issue = payload.issue;
            const comment = payload.comment;
            
            if (payload.action === 'created') {
                return {
                    message: `[GitHub] New comment on #${issue.number} in ${repo}\n\nBy: ${sender}\n\n${comment.body}`,
                    sessionKey: `github:${repo}:issue:${issue.number}`,
                    priority: 'normal'
                };
            }
            break;
        }
        
        case 'pull_request': {
            const pr = payload.pull_request;
            const action = payload.action;
            
            if (action === 'opened') {
                return {
                    message: `[GitHub] New PR #${pr.number} in ${repo}: ${pr.title}\n\nBy: ${sender}\n\n${pr.body || '(no description)'}\n\nBranch: ${pr.head.ref} → ${pr.base.ref}`,
                    sessionKey: `github:${repo}:pr:${pr.number}`,
                    priority: 'high'
                };
            } else if (action === 'closed') {
                const merged = pr.merged ? 'merged' : 'closed without merge';
                return {
                    message: `[GitHub] PR #${pr.number} ${merged} in ${repo}: ${pr.title}`,
                    sessionKey: `github:${repo}:pr:${pr.number}`,
                    priority: 'normal'
                };
            }
            break;
        }
        
        case 'pull_request_review': {
            const pr = payload.pull_request;
            const review = payload.review;
            
            if (payload.action === 'submitted') {
                const state = review.state; // approved, changes_requested, commented
                return {
                    message: `[GitHub] PR #${pr.number} review (${state}) in ${repo}\n\nBy: ${sender}\n\n${review.body || '(no comment)'}`,
                    sessionKey: `github:${repo}:pr:${pr.number}`,
                    priority: state === 'changes_requested' ? 'high' : 'normal'
                };
            }
            break;
        }
        
        case 'push': {
            const commits = payload.commits || [];
            const branch = payload.ref?.replace('refs/heads/', '') || 'unknown';
            
            if (commits.length === 0) return null;
            
            const commitSummary = commits.slice(0, 5).map(c => 
                `- ${c.message.split('\n')[0]} (${c.id.slice(0, 7)})`
            ).join('\n');
            
            return {
                message: `[GitHub] ${commits.length} commit(s) pushed to ${repo}:${branch}\n\nBy: ${sender}\n\n${commitSummary}${commits.length > 5 ? `\n... and ${commits.length - 5} more` : ''}`,
                sessionKey: `github:${repo}:push`,
                priority: 'low'
            };
        }
        
        case 'release': {
            const release = payload.release;
            
            if (payload.action === 'published') {
                return {
                    message: `[GitHub] New release ${release.tag_name} in ${repo}: ${release.name || release.tag_name}\n\nBy: ${sender}\n\n${release.body || '(no release notes)'}`,
                    sessionKey: `github:${repo}:release:${release.tag_name}`,
                    priority: 'high'
                };
            }
            break;
        }
        
        case 'ping': {
            return {
                message: `[GitHub] Webhook configured for ${repo}. Zen: ${payload.zen}`,
                sessionKey: `github:${repo}:ping`,
                priority: 'low'
            };
        }
        
        default:
            return null;
    }
    
    return null;
}

// Forward to Clawdbot
async function forwardToClawdbot(transformed, context) {
    const url = process.env.CLAWDBOT_WEBHOOK_URL;
    const token = process.env.CLAWDBOT_WEBHOOK_TOKEN;
    const deliverChannel = process.env.DELIVER_TO_CHANNEL;
    const deliverTo = process.env.DELIVER_TO;
    
    if (!url || !token) {
        context.error('Missing CLAWDBOT_WEBHOOK_URL or CLAWDBOT_WEBHOOK_TOKEN');
        return false;
    }
    
    const payload = {
        message: transformed.message,
        name: 'GitHub',
        sessionKey: transformed.sessionKey,
        deliver: true,
        wakeMode: transformed.priority === 'high' ? 'now' : 'next-heartbeat'
    };
    
    if (deliverChannel) {
        payload.channel = deliverChannel;
    }
    if (deliverTo) {
        payload.to = deliverTo;
    }
    
    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify(payload)
        });
        
        if (!response.ok) {
            context.error(`Clawdbot returned ${response.status}: ${await response.text()}`);
            return false;
        }
        
        context.log(`Forwarded to Clawdbot: ${transformed.sessionKey}`);
        return true;
    } catch (err) {
        context.error(`Failed to forward to Clawdbot: ${err.message}`);
        return false;
    }
}

app.http('github', {
    methods: ['POST'],
    authLevel: 'anonymous',
    handler: async (request, context) => {
        const event = request.headers.get('x-github-event');
        const signature = request.headers.get('x-hub-signature-256');
        const delivery = request.headers.get('x-github-delivery');
        
        context.log(`GitHub webhook: event=${event}, delivery=${delivery}`);
        
        // Get raw body for signature verification
        const body = await request.text();
        
        // Verify signature
        const secret = process.env.GITHUB_WEBHOOK_SECRET;
        if (secret && !verifySignature(body, signature, secret)) {
            context.warn('Invalid GitHub signature');
            return { status: 401, body: 'Invalid signature' };
        }
        
        // Parse payload
        let payload;
        try {
            payload = JSON.parse(body);
        } catch (err) {
            return { status: 400, body: 'Invalid JSON' };
        }
        
        // Check repo filter
        const reposFilter = process.env.REPOS_FILTER;
        if (reposFilter) {
            const allowedRepos = reposFilter.split(',').map(r => r.trim());
            const repo = payload.repository?.full_name;
            if (repo && !allowedRepos.includes(repo)) {
                context.log(`Repo ${repo} not in filter, skipping`);
                return { status: 200, body: 'Filtered' };
            }
        }
        
        // Transform event
        const transformed = transformEvent(event, payload);
        
        if (!transformed) {
            context.log(`Event ${event}/${payload.action} not handled`);
            return { status: 200, body: 'Event not handled' };
        }
        
        // Forward to Clawdbot
        const success = await forwardToClawdbot(transformed, context);
        
        return {
            status: success ? 200 : 500,
            body: success ? 'Forwarded' : 'Forward failed'
        };
    }
});

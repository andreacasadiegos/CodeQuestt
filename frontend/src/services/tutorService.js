import { apiRequest } from './api.js';

export function getConversations() {
  return apiRequest('/tutor/conversations');
}

export function createConversation() {
  return apiRequest('/tutor/conversations', { method: 'POST', body: {} });
}

export function getConversation(id) {
  return apiRequest(`/tutor/conversations/${id}`);
}

export function sendTutorMessage(id, message) {
  return apiRequest(`/tutor/conversations/${id}/messages`, {
    method: 'POST',
    body: { message },
  });
}

export function archiveConversation(id) {
  return apiRequest(`/tutor/conversations/${id}/archive`, { method: 'POST', body: {} });
}

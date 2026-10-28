const BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api';

const getHeaders = () => {
  const token = localStorage.getItem('unify_admin_token');
  return {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  };
};

export const api = {
  async login(email, password) {
    const res = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Login failed');
    return data;
  },

  async getStats() {
    const res = await fetch(`${BASE_URL}/admin/stats`, {
      headers: getHeaders(),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Failed to fetch stats');
    return data;
  },

  async getUsers() {
    const res = await fetch(`${BASE_URL}/admin/users`, {
      headers: getHeaders(),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Failed to fetch users');
    return data;
  },

  async getEmployers() {
    const res = await fetch(`${BASE_URL}/admin/employers`, {
      headers: getHeaders(),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Failed to fetch employers');
    return data;
  },

  async verifyEmployer(id, status) {
    const res = await fetch(`${BASE_URL}/admin/employers/${id}/verify`, {
      method: 'PUT',
      headers: getHeaders(),
      body: JSON.stringify({ status }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Failed to verify employer');
    return data;
  },

  async getOpportunities() {
    const res = await fetch(`${BASE_URL}/admin/opportunities`, {
      headers: getHeaders(),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Failed to fetch opportunities');
    return data;
  },

  async createOpportunity(opportunityData) {
    const res = await fetch(`${BASE_URL}/admin/opportunities`, {
      method: 'POST',
      headers: getHeaders(),
      body: JSON.stringify(opportunityData),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Failed to create opportunity');
    return data;
  },

  async updateOpportunity(id, opportunityData) {
    const res = await fetch(`${BASE_URL}/admin/opportunities/${id}`, {
      method: 'PUT',
      headers: getHeaders(),
      body: JSON.stringify(opportunityData),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Failed to update opportunity');
    return data;
  },

  async deleteOpportunity(id) {
    const res = await fetch(`${BASE_URL}/admin/opportunities/${id}`, {
      method: 'DELETE',
      headers: getHeaders(),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Failed to delete opportunity');
    return data;
  },

  async getApplications() {
    const res = await fetch(`${BASE_URL}/admin/applications`, {
      headers: getHeaders(),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Failed to fetch applications');
    return data;
  },

  async updateApplicationStatus(id, status) {
    const res = await fetch(`${BASE_URL}/admin/applications/${id}/status`, {
      method: 'PUT',
      headers: getHeaders(),
      body: JSON.stringify({ status }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Failed to update application status');
    return data;
  },

  async verifyStudentResume(studentId, isVerified) {
    const res = await fetch(`${BASE_URL}/admin/students/${studentId}/verify-resume`, {
      method: 'PUT',
      headers: getHeaders(),
      body: JSON.stringify({ isVerified }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Failed to update resume verification');
    return data;
  },

  async getReports() {
    const res = await fetch(`${BASE_URL}/admin/reports`, {
      headers: getHeaders(),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Failed to fetch reports');
    return data;
  },

  async resolveReport(id, status) {
    const res = await fetch(`${BASE_URL}/admin/reports/${id}/resolve`, {
      method: 'PUT',
      headers: getHeaders(),
      body: JSON.stringify({ status }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.message || 'Failed to resolve report');
    return data;
  },
};

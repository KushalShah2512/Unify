import React, { useState, useEffect } from 'react';
import Sidebar from './components/Sidebar';
import OverviewTab from './components/OverviewTab';
import UsersTab from './components/UsersTab';
import EmployersTab from './components/EmployersTab';
import OpportunitiesTab from './components/OpportunitiesTab';
import ApplicationsTab from './components/ApplicationsTab';
import ModerationTab from './components/ModerationTab';
import LoginView from './components/LoginView';
import { api } from './api';
import { RefreshCw, CheckCircle } from 'lucide-react';

export default function App() {
  const [token, setToken] = useState(localStorage.getItem('unify_admin_token') || '');
  const [user, setUser] = useState(() => {
    const saved = localStorage.getItem('unify_admin_user');
    return saved ? JSON.parse(saved) : null;
  });

  const [activeTab, setActiveTab] = useState('overview');
  const [stats, setStats] = useState(null);
  const [recentUsers, setRecentUsers] = useState([]);
  const [users, setUsers] = useState([]);
  const [employers, setEmployers] = useState([]);
  const [opportunities, setOpportunities] = useState([]);
  const [applications, setApplications] = useState([]);
  const [reports, setReports] = useState([]);

  const [loading, setLoading] = useState(false);
  const [loginLoading, setLoginLoading] = useState(false);
  const [loginError, setLoginError] = useState('');
  const [toast, setToast] = useState('');

  const showToast = (msg) => {
    setToast(msg);
    setTimeout(() => setToast(''), 4000);
  };

  // Login handler
  const handleLogin = async (email, password) => {
    try {
      setLoginLoading(true);
      setLoginError('');
      const data = await api.login(email, password);

      if (data.user?.role !== 'ADMIN') {
        throw new Error('Access denied. Administrator privileges required.');
      }

      localStorage.setItem('unify_admin_token', data.token);
      localStorage.setItem('unify_admin_user', JSON.stringify(data.user));
      setToken(data.token);
      setUser(data.user);
      showToast('Welcome back, Administrator!');
    } catch (err) {
      setLoginError(err.message || 'Authentication failed');
    } finally {
      setLoginLoading(false);
    }
  };

  // Logout handler
  const handleLogout = () => {
    localStorage.removeItem('unify_admin_token');
    localStorage.removeItem('unify_admin_user');
    setToken('');
    setUser(null);
  };

  // Fetch all admin data
  const fetchData = async () => {
    if (!token) return;
    try {
      setLoading(true);
      const [statsRes, usersRes, employersRes, oppsRes, appsRes, reportsRes] = await Promise.all([
        api.getStats().catch(() => null),
        api.getUsers().catch(() => null),
        api.getEmployers().catch(() => null),
        api.getOpportunities().catch(() => null),
        api.getApplications().catch(() => null),
        api.getReports().catch(() => null),
      ]);

      if (statsRes?.stats) {
        setStats(statsRes.stats);
        setRecentUsers(statsRes.recentUsers || []);
      }
      if (usersRes?.users) setUsers(usersRes.users);
      if (employersRes?.employers) setEmployers(employersRes.employers);
      if (oppsRes?.opportunities) setOpportunities(oppsRes.opportunities);
      if (appsRes?.applications) setApplications(appsRes.applications);
      if (reportsRes?.reports) setReports(reportsRes.reports);
    } catch (err) {
      console.error('Fetch data error:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (token) {
      fetchData();
    }
  }, [token]);

  // Employer verification action
  const handleVerifyEmployer = async (id, status) => {
    try {
      await api.verifyEmployer(id, status);
      showToast(`Organization status updated to ${status}`);
      fetchData();
    } catch (err) {
      showToast(err.message || 'Failed to update status');
    }
  };

  // Opportunity create action
  const handleCreateOpportunity = async (data) => {
    try {
      await api.createOpportunity(data);
      showToast('Opportunity published successfully');
      fetchData();
    } catch (err) {
      showToast(err.message || 'Failed to create opportunity');
    }
  };

  // Opportunity update action
  const handleUpdateOpportunity = async (id, data) => {
    try {
      await api.updateOpportunity(id, data);
      showToast('Opportunity updated successfully');
      fetchData();
    } catch (err) {
      showToast(err.message || 'Failed to update opportunity');
    }
  };

  // Opportunity delete action
  const handleDeleteOpportunity = async (id) => {
    if (!window.confirm('Are you sure you want to delete this opportunity?')) return;
    try {
      await api.deleteOpportunity(id);
      showToast('Opportunity removed successfully');
      fetchData();
    } catch (err) {
      showToast(err.message || 'Failed to delete opportunity');
    }
  };

  // Candidate application status update
  const handleUpdateApplicationStatus = async (id, status) => {
    try {
      await api.updateApplicationStatus(id, status);
      showToast(`Candidate marked as ${status}`);
      fetchData();
    } catch (err) {
      showToast(err.message || 'Failed to update application');
    }
  };

  // Candidate Resume Verification action
  const handleVerifyResume = async (studentId, isVerified) => {
    try {
      await api.verifyStudentResume(studentId, isVerified);
      showToast(isVerified ? 'Candidate resume verified successfully!' : 'Resume marked as unverified');
      fetchData();
    } catch (err) {
      showToast(err.message || 'Failed to update resume verification');
    }
  };

  // Moderation Report action
  const handleResolveReport = async (id, status) => {
    try {
      await api.resolveReport(id, status);
      showToast(`Report marked as ${status.toLowerCase()}`);
      fetchData();
    } catch (err) {
      showToast(err.message || 'Failed to update report');
    }
  };

  if (!token) {
    return (
      <LoginView 
        onLogin={handleLogin} 
        error={loginError} 
        loading={loginLoading} 
      />
    );
  }

  const tabTitles = {
    overview: 'Platform Analytics & Overview',
    users: 'User Account Management',
    employers: 'Organization Verifications',
    opportunities: 'Opportunities & Job Portal',
    applications: 'Candidate Application Pipeline',
    moderation: 'Job Safety & Fraud Listing Moderation',
  };

  const pendingReportsCount = reports.filter((r) => r.status === 'PENDING').length;

  return (
    <div className="admin-layout">
      {/* Sidebar Navigation */}
      <Sidebar 
        activeTab={activeTab} 
        setActiveTab={setActiveTab} 
        pendingCount={stats?.pendingEmployers || 0}
        reportsCount={pendingReportsCount}
        user={user}
        onLogout={handleLogout}
      />

      {/* Main Content Area */}
      <div className="main-wrapper">
        <header className="top-navbar">
          <div className="page-title">
            {tabTitles[activeTab]}
          </div>

          <div className="top-actions">
            <div className="status-pill">
              <span className="status-dot"></span>
              <span>API Connected</span>
            </div>

            <button 
              className="btn btn-secondary" 
              onClick={fetchData}
              title="Refresh Data"
            >
              <RefreshCw size={14} className={loading ? 'animate-spin' : ''} />
              <span>Refresh</span>
            </button>
          </div>
        </header>

        <main className="content-area">
          {activeTab === 'overview' && (
            <OverviewTab 
              stats={stats} 
              recentUsers={recentUsers}
              onNavigateTab={setActiveTab}
            />
          )}

          {activeTab === 'users' && (
            <UsersTab 
              users={users} 
              loading={loading}
            />
          )}

          {activeTab === 'employers' && (
            <EmployersTab 
              employers={employers} 
              onVerify={handleVerifyEmployer}
              loading={loading}
            />
          )}

          {activeTab === 'opportunities' && (
            <OpportunitiesTab 
              opportunities={opportunities} 
              onCreate={handleCreateOpportunity}
              onUpdate={handleUpdateOpportunity}
              onDelete={handleDeleteOpportunity}
              loading={loading}
            />
          )}

          {activeTab === 'applications' && (
            <ApplicationsTab 
              applications={applications}
              onUpdateStatus={handleUpdateApplicationStatus}
              onVerifyResume={handleVerifyResume}
              loading={loading}
            />
          )}

          {activeTab === 'moderation' && (
            <ModerationTab 
              reports={reports}
              onResolveReport={handleResolveReport}
              onDeleteOpportunity={handleDeleteOpportunity}
              loading={loading}
            />
          )}
        </main>
      </div>

      {/* Toast Notification */}
      {toast && (
        <div className="toast-notice">
          <CheckCircle size={18} color="#34d399" />
          <span>{toast}</span>
        </div>
      )}
    </div>
  );
}

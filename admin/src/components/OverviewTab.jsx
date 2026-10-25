import React from 'react';
import { Users, GraduationCap, Building2, Briefcase, Clock, ShieldAlert } from 'lucide-react';

export default function OverviewTab({ stats, recentUsers, onNavigateTab }) {
  return (
    <div>
      {/* Platform Stats Row */}
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-meta">
            <p>Total Registered Users</p>
            <h3>{stats?.totalUsers || 0}</h3>
          </div>
          <div className="stat-icon indigo">
            <Users size={24} />
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-meta">
            <p>Students Enrolled</p>
            <h3>{stats?.totalStudents || 0}</h3>
          </div>
          <div className="stat-icon cyan">
            <GraduationCap size={24} />
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-meta">
            <p>Organizations / Employers</p>
            <h3>{stats?.totalEmployers || 0}</h3>
          </div>
          <div className="stat-icon emerald">
            <Building2 size={24} />
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-meta">
            <p>Active Opportunities</p>
            <h3>{stats?.totalOpportunities || 0}</h3>
          </div>
          <div className="stat-icon amber">
            <Briefcase size={24} />
          </div>
        </div>
      </div>

      {/* Pending Verifications Notice banner if any */}
      {stats?.pendingEmployers > 0 && (
        <div 
          style={{
            background: 'linear-gradient(90deg, rgba(245, 158, 11, 0.15), rgba(245, 158, 11, 0.05))',
            border: '1px solid rgba(245, 158, 11, 0.3)',
            borderRadius: '16px',
            padding: '18px 24px',
            marginBottom: '32px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            flexWrap: 'wrap',
            gap: '16px'
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
            <div style={{ background: 'rgba(245, 158, 11, 0.2)', padding: '10px', borderRadius: '12px', color: '#fbbf24' }}>
              <ShieldAlert size={24} />
            </div>
            <div>
              <h4 style={{ color: '#fff', fontSize: '15px', fontWeight: '700' }}>
                {stats.pendingEmployers} Employer Verification{stats.pendingEmployers > 1 ? 's' : ''} Pending
              </h4>
              <p style={{ color: '#94a3b8', fontSize: '13px' }}>
                Review and approve employer organization profiles to grant hiring and posting access.
              </p>
            </div>
          </div>
          <button 
            className="btn btn-primary"
            onClick={() => onNavigateTab('employers')}
          >
            Review Requests
          </button>
        </div>
      )}

      {/* Recent Activity Table */}
      <div className="panel">
        <div className="panel-header">
          <div className="panel-title">
            <h2>Recent Registrations</h2>
            <p>Latest users and accounts created on Unify</p>
          </div>
          <button 
            className="btn btn-secondary"
            onClick={() => onNavigateTab('users')}
          >
            View All Users
          </button>
        </div>

        <div className="data-table-container">
          <table className="data-table">
            <thead>
              <tr>
                <th>User / Email</th>
                <th>Role</th>
                <th>Associated Profile</th>
                <th>Joined Date</th>
              </tr>
            </thead>
            <tbody>
              {recentUsers && recentUsers.length > 0 ? (
                recentUsers.map((u) => {
                  const roleClass = 
                    u.role === 'STUDENT' ? 'badge-student' :
                    u.role === 'EMPLOYER' ? 'badge-employer' : 'badge-admin';
                  
                  const profileName = 
                    u.studentProfile?.fullName || 
                    u.employerProfile?.companyName || 
                    'Account Setup Pending';

                  return (
                    <tr key={u.id}>
                      <td>
                        <strong style={{ color: '#fff' }}>{u.email}</strong>
                      </td>
                      <td>
                        <span className={`badge ${roleClass}`}>{u.role}</span>
                      </td>
                      <td>{profileName}</td>
                      <td>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                          <Clock size={14} color="#64748b" />
                          <span>{new Date(u.createdAt).toLocaleDateString()}</span>
                        </div>
                      </td>
                    </tr>
                  );
                })
              ) : (
                <tr>
                  <td colSpan="4" style={{ textAlign: 'center', padding: '32px' }}>
                    No recent registrations recorded.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

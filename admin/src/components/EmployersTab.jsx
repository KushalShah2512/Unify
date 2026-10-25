import React, { useState } from 'react';
import { Building2, CheckCircle2, XCircle, Clock, ExternalLink } from 'lucide-react';

export default function EmployersTab({ employers, onVerify, loading }) {
  const [filter, setFilter] = useState('ALL');

  const filtered = (employers || []).filter((emp) => {
    if (filter === 'ALL') return true;
    return emp.verificationStatus === filter;
  });

  return (
    <div className="panel">
      <div className="panel-header">
        <div className="panel-title">
          <h2>Employer Verifications ({filtered.length})</h2>
          <p>Review organization credentials and manage account approval</p>
        </div>

        <div className="table-controls">
          <select 
            className="custom-select"
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
          >
            <option value="ALL">All Statuses</option>
            <option value="PENDING">Pending Review</option>
            <option value="APPROVED">Approved</option>
            <option value="REJECTED">Rejected</option>
          </select>
        </div>
      </div>

      <div className="data-table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Company Name</th>
              <th>Account Email</th>
              <th>Industry & Location</th>
              <th>Website</th>
              <th>Status</th>
              <th style={{ textAlign: 'right' }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '36px' }}>
                  Loading employer organizations...
                </td>
              </tr>
            ) : filtered.length > 0 ? (
              filtered.map((emp) => {
                const isPending = emp.verificationStatus === 'PENDING';
                const isApproved = emp.verificationStatus === 'APPROVED';
                const isRejected = emp.verificationStatus === 'REJECTED';

                const badgeClass = 
                  isApproved ? 'badge-approved' : 
                  isPending ? 'badge-pending' : 'badge-rejected';

                return (
                  <tr key={emp.id}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                        <div style={{ background: 'rgba(99, 102, 241, 0.1)', padding: '8px', borderRadius: '8px' }}>
                          <Building2 size={16} color="#818cf8" />
                        </div>
                        <strong style={{ color: '#fff', fontSize: '14px' }}>
                          {emp.companyName}
                        </strong>
                      </div>
                    </td>
                    <td>{emp.user?.email || '—'}</td>
                    <td>
                      <div>{emp.industry || 'General Industry'}</div>
                      <div style={{ fontSize: '11px', color: '#64748b' }}>{emp.location || 'Remote/Unspecified'}</div>
                    </td>
                    <td>
                      {emp.website ? (
                        <a 
                          href={emp.website.startsWith('http') ? emp.website : `https://${emp.website}`}
                          target="_blank"
                          rel="noreferrer"
                          style={{ color: '#38bdf8', display: 'flex', alignItems: 'center', gap: '4px', textDecoration: 'none' }}
                        >
                          Visit <ExternalLink size={12} />
                        </a>
                      ) : (
                        '—'
                      )}
                    </td>
                    <td>
                      <span className={`badge ${badgeClass}`}>
                        {emp.verificationStatus}
                      </span>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                        {!isApproved && (
                          <button 
                            className="btn btn-success"
                            style={{ padding: '6px 12px', fontSize: '12px' }}
                            onClick={() => onVerify(emp.id, 'APPROVED')}
                          >
                            <CheckCircle2 size={14} /> Approve
                          </button>
                        )}
                        {!isRejected && (
                          <button 
                            className="btn btn-danger"
                            style={{ padding: '6px 12px', fontSize: '12px' }}
                            onClick={() => onVerify(emp.id, 'REJECTED')}
                          >
                            <XCircle size={14} /> Reject
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                );
              })
            ) : (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '36px' }}>
                  No employer profiles found in this category.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

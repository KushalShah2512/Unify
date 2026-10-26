import React, { useState } from 'react';
import { AlertTriangle, CheckCircle, XCircle, Clock, ShieldAlert, ExternalLink, Trash2 } from 'lucide-react';

export default function ModerationTab({ reports, onResolveReport, onDeleteOpportunity, loading }) {
  const [filter, setFilter] = useState('ALL');

  const filtered = (reports || []).filter((r) => {
    if (filter === 'ALL') return true;
    return r.status === filter;
  });

  return (
    <div className="panel">
      <div className="panel-header">
        <div className="panel-title">
          <h2>Safety & Fraud Moderation ({filtered.length})</h2>
          <p>Review suspicious job postings reported by students (scams, fee requests, or fake employers)</p>
        </div>

        <div className="table-controls">
          <select 
            className="custom-select"
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
          >
            <option value="ALL">All Reports</option>
            <option value="PENDING">Pending Review</option>
            <option value="RESOLVED">Resolved / Action Taken</option>
            <option value="DISMISSED">Dismissed</option>
          </select>
        </div>
      </div>

      <div className="data-table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Reported Opportunity</th>
              <th>Flagged Reason</th>
              <th>Student Details</th>
              <th>Report Date</th>
              <th>Status</th>
              <th style={{ textAlign: 'right' }}>Moderation Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '36px' }}>
                  Loading moderation reports...
                </td>
              </tr>
            ) : filtered.length > 0 ? (
              filtered.map((item) => {
                const opp = item.opportunity;
                const student = item.student;
                const isPending = item.status === 'PENDING';

                return (
                  <tr key={item.id}>
                    <td>
                      <div>
                        <strong style={{ color: '#f87171', fontSize: '14px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                          <AlertTriangle size={14} />
                          {opp?.title || 'Unknown Opportunity'}
                        </strong>
                        <div style={{ fontSize: '11px', color: '#94a3b8' }}>
                          {opp?.companyName || 'Unknown Employer'}
                        </div>
                      </div>
                    </td>
                    <td>
                      <div>
                        <span 
                          style={{
                            background: 'rgba(239, 68, 68, 0.15)',
                            color: '#fca5a5',
                            border: '1px solid rgba(239, 68, 68, 0.3)',
                            padding: '3px 8px',
                            borderRadius: '6px',
                            fontSize: '11px',
                            fontWeight: '600',
                          }}
                        >
                          {item.reason}
                        </span>
                        {item.details && (
                          <div style={{ fontSize: '11px', color: '#cbd5e1', marginTop: '4px', maxWidth: '280px', fontStyle: 'italic' }}>
                            "{item.details}"
                          </div>
                        )}
                      </div>
                    </td>
                    <td>
                      <div style={{ fontSize: '12px', color: '#e2e8f0' }}>
                        {student?.fullName || 'Anonymous Student'}
                        <div style={{ fontSize: '11px', color: '#64748b' }}>
                          {student?.user?.email || ''}
                        </div>
                      </div>
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '12px', color: '#94a3b8' }}>
                        <Clock size={13} />
                        <span>{new Date(item.createdAt).toLocaleDateString()}</span>
                      </div>
                    </td>
                    <td>
                      <span className={`badge ${item.status === 'RESOLVED' ? 'badge-approved' : item.status === 'DISMISSED' ? 'badge-rejected' : 'badge-pending'}`}>
                        {item.status}
                      </span>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <div style={{ display: 'flex', gap: '6px', justifyContent: 'flex-end', alignItems: 'center' }}>
                        {isPending && (
                          <>
                            <button
                              className="btn btn-primary"
                              style={{ 
                                padding: '5px 8px', 
                                fontSize: '11px', 
                                background: '#10b981', 
                                borderColor: '#10b981' 
                              }}
                              title="Resolve Report"
                              onClick={() => onResolveReport(item.id, 'RESOLVED')}
                            >
                              Resolve
                            </button>
                            <button
                              className="btn btn-secondary"
                              style={{ padding: '5px 8px', fontSize: '11px' }}
                              title="Dismiss Report"
                              onClick={() => onResolveReport(item.id, 'DISMISSED')}
                            >
                              Dismiss
                            </button>
                          </>
                        )}
                        {opp?.id && onDeleteOpportunity && (
                          <button
                            className="btn btn-secondary"
                            style={{ padding: '5px 8px', fontSize: '11px', color: '#ef4444' }}
                            title="Remove Opportunity from Portal"
                            onClick={() => onDeleteOpportunity(opp.id)}
                          >
                            <Trash2 size={12} /> Take Down
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                );
              })
            ) : (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '36px', color: '#64748b' }}>
                  No moderation reports matching criteria. Campus listings are clean!
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

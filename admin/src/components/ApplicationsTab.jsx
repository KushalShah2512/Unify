import React, { useState } from 'react';
import { UserCheck, Briefcase, Mail, CheckCircle2, XCircle, Clock, Eye, X, FileText, Phone, Award, GraduationCap } from 'lucide-react';

export default function ApplicationsTab({ applications, onUpdateStatus, loading }) {
  const [filter, setFilter] = useState('ALL');
  const [selectedApp, setSelectedApp] = useState(null);

  const filtered = (applications || []).filter((app) => {
    if (filter === 'ALL') return true;
    return app.status === filter;
  });

  const getStatusBadge = (status) => {
    switch (status) {
      case 'ACCEPTED':
        return 'badge-approved';
      case 'SHORTLISTED':
        return 'badge-student';
      case 'UNDER_REVIEW':
        return 'badge-pending';
      case 'REJECTED':
        return 'badge-rejected';
      default:
        return 'badge-pending';
    }
  };

  return (
    <div className="panel">
      <div className="panel-header">
        <div className="panel-title">
          <h2>Candidate Applications ({filtered.length})</h2>
          <p>Review student applications and track recruitment pipeline</p>
        </div>

        <div className="table-controls">
          <select 
            className="custom-select"
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
          >
            <option value="ALL">All Application Stages</option>
            <option value="APPLIED">New / Applied</option>
            <option value="UNDER_REVIEW">Under Review</option>
            <option value="SHORTLISTED">Shortlisted</option>
            <option value="ACCEPTED">Accepted / Offered</option>
            <option value="REJECTED">Rejected</option>
          </select>
        </div>
      </div>

      <div className="data-table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Applicant Name</th>
              <th>Opportunity Applied</th>
              <th>Applicant Skills</th>
              <th>Applied Date</th>
              <th>Status</th>
              <th style={{ textAlign: 'right' }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '36px' }}>
                  Loading candidate applications...
                </td>
              </tr>
            ) : filtered.length > 0 ? (
              filtered.map((app) => {
                const studentName = app.student?.fullName || 'Student';
                const studentEmail = app.student?.user?.email || '—';
                const oppTitle = app.opportunity?.title || 'Opportunity';
                const oppCompany = app.opportunity?.companyName || '';
                const skills = (app.student?.skills || []).map((s) => s.name);

                return (
                  <tr key={app.id}>
                    <td>
                      <div>
                        <strong style={{ color: '#fff', fontSize: '14px' }}>{studentName}</strong>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '11px', color: '#94a3b8' }}>
                          <Mail size={12} /> {studentEmail}
                        </div>
                      </div>
                    </td>
                    <td>
                      <div>
                        <strong style={{ color: '#818cf8' }}>{oppTitle}</strong>
                        <div style={{ fontSize: '11px', color: '#64748b' }}>{oppCompany}</div>
                      </div>
                    </td>
                    <td>
                      <div style={{ display: 'flex', gap: '4px', flexWrap: 'wrap', maxWidth: '200px' }}>
                        {skills.slice(0, 3).map((s, idx) => (
                          <span 
                            key={idx}
                            style={{
                              background: 'rgba(255,255,255,0.06)',
                              padding: '2px 6px',
                              borderRadius: '4px',
                              fontSize: '11px',
                              color: '#cbd5e1'
                            }}
                          >
                            {s}
                          </span>
                        ))}
                        {skills.length > 3 && (
                          <span style={{ fontSize: '11px', color: '#64748b' }}>+{skills.length - 3}</span>
                        )}
                      </div>
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                        <Clock size={13} color="#64748b" />
                        <span>{new Date(app.appliedAt).toLocaleDateString()}</span>
                      </div>
                    </td>
                    <td>
                      <span className={`badge ${getStatusBadge(app.status)}`}>
                        {app.status}
                      </span>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <div style={{ display: 'flex', gap: '6px', justifyContent: 'flex-end', alignItems: 'center' }}>
                        <button
                          className="btn btn-secondary"
                          style={{ padding: '5px 8px', fontSize: '11px', display: 'flex', alignItems: 'center', gap: '4px' }}
                          title="View Full Profile & Application"
                          onClick={() => setSelectedApp(app)}
                        >
                          <Eye size={12} /> Review
                        </button>

                        {app.status !== 'SHORTLISTED' && app.status !== 'ACCEPTED' && (
                          <button 
                            className="btn btn-secondary"
                            style={{ padding: '5px 10px', fontSize: '11px' }}
                            onClick={() => onUpdateStatus(app.id, 'SHORTLISTED')}
                          >
                            Shortlist
                          </button>
                        )}
                        {app.status !== 'ACCEPTED' && (
                          <button 
                            className="btn btn-success"
                            style={{ padding: '5px 10px', fontSize: '11px' }}
                            onClick={() => onUpdateStatus(app.id, 'ACCEPTED')}
                          >
                            <CheckCircle2 size={12} /> Accept
                          </button>
                        )}
                        {app.status !== 'REJECTED' && (
                          <button 
                            className="btn btn-danger"
                            style={{ padding: '5px 10px', fontSize: '11px' }}
                            onClick={() => onUpdateStatus(app.id, 'REJECTED')}
                          >
                            <XCircle size={12} /> Reject
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
                  No candidate applications recorded yet. Applications submitted from the mobile app will appear here!
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Candidate Application & Profile Review Modal */}
      {selectedApp && (
        <div className="modal-backdrop">
          <div className="modal-content" style={{ maxWidth: '640px' }}>
            <div className="modal-header">
              <div>
                <h3 style={{ margin: 0, color: '#fff', fontSize: '18px' }}>Candidate Application Dossier</h3>
                <p style={{ margin: '4px 0 0 0', color: '#94a3b8', fontSize: '12px' }}>
                  Applied for <span style={{ color: '#818cf8', fontWeight: 'bold' }}>{selectedApp.opportunity?.title}</span> at {selectedApp.opportunity?.companyName}
                </p>
              </div>
              <button 
                className="icon-button"
                onClick={() => setSelectedApp(null)}
              >
                <X size={18} />
              </button>
            </div>

            <div style={{ maxHeight: '70vh', overflowY: 'auto', padding: '16px 0' }}>
              {/* Candidate Info Box */}
              <div style={{ background: 'rgba(255,255,255,0.03)', border: '1px solid rgba(255,255,255,0.08)', borderRadius: '10px', padding: '14px', marginBottom: '14px' }}>
                <h4 style={{ margin: '0 0 8px 0', color: '#fff', fontSize: '15px' }}>
                  {selectedApp.student?.fullName || 'Candidate'}
                </h4>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '8px', fontSize: '12px', color: '#cbd5e1' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <Mail size={13} color="#818cf8" /> {selectedApp.student?.user?.email || 'N/A'}
                  </div>
                  {selectedApp.student?.phoneNumber && (
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <Phone size={13} color="#818cf8" /> {selectedApp.student.phoneNumber}
                    </div>
                  )}
                  {selectedApp.student?.careerGoal && (
                    <div style={{ gridColumn: '1 / -1', color: '#94a3b8' }}>
                      <strong>Target Role:</strong> {selectedApp.student.careerGoal}
                    </div>
                  )}
                </div>
              </div>

              {/* Cover Letter / Pitch */}
              {selectedApp.coverLetter && (
                <div style={{ background: 'rgba(99, 102, 241, 0.06)', border: '1px solid rgba(99, 102, 241, 0.2)', borderRadius: '10px', padding: '12px', marginBottom: '14px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#818cf8', fontSize: '13px', fontWeight: 'bold', marginBottom: '6px' }}>
                    <FileText size={14} /> Candidate Pitch / Cover Note
                  </div>
                  <p style={{ margin: 0, fontSize: '13px', color: '#e2e8f0', lineHeight: 1.5 }}>
                    {selectedApp.coverLetter}
                  </p>
                </div>
              )}

              {/* Resume / Portfolio Link */}
              {selectedApp.student?.resumeUrl && (
                <div style={{ marginBottom: '14px' }}>
                  <a 
                    href={selectedApp.student.resumeUrl}
                    target="_blank"
                    rel="noreferrer"
                    className="btn btn-primary"
                    style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', fontSize: '12px', padding: '8px 14px' }}
                  >
                    <FileText size={14} /> Open Candidate Resume Document
                  </a>
                </div>
              )}

              {/* Skills */}
              <div style={{ marginBottom: '14px' }}>
                <strong style={{ fontSize: '12px', color: '#94a3b8', textTransform: 'uppercase' }}>Verified Skills</strong>
                <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap', marginTop: '6px' }}>
                  {(selectedApp.student?.skills || []).map((s, idx) => (
                    <span 
                      key={idx}
                      style={{
                        background: 'rgba(99, 102, 241, 0.15)',
                        border: '1px solid rgba(99, 102, 241, 0.3)',
                        padding: '4px 8px',
                        borderRadius: '6px',
                        fontSize: '11px',
                        color: '#c7d2fe'
                      }}
                    >
                      {s.name} ({s.level})
                    </span>
                  ))}
                  {(!selectedApp.student?.skills || selectedApp.student.skills.length === 0) && (
                    <span style={{ fontSize: '12px', color: '#64748b' }}>No skills listed</span>
                  )}
                </div>
              </div>

              {/* Education */}
              {selectedApp.student?.educationRecords && selectedApp.student.educationRecords.length > 0 && (
                <div style={{ marginBottom: '14px' }}>
                  <strong style={{ fontSize: '12px', color: '#94a3b8', textTransform: 'uppercase' }}>Education</strong>
                  <div style={{ marginTop: '6px', display: 'flex', flexDirection: 'column', gap: '6px' }}>
                    {selectedApp.student.educationRecords.map((edu, idx) => (
                      <div key={idx} style={{ background: 'rgba(255,255,255,0.03)', padding: '8px 12px', borderRadius: '6px', fontSize: '12px' }}>
                        <div style={{ fontWeight: 'bold', color: '#fff' }}>{edu.degree} - {edu.fieldOfStudy || ''}</div>
                        <div style={{ color: '#94a3b8' }}>{edu.institution}</div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Current Pipeline Status Selector */}
              <div style={{ background: 'rgba(255,255,255,0.03)', border: '1px solid rgba(255,255,255,0.1)', borderRadius: '10px', padding: '14px', marginTop: '16px' }}>
                <label style={{ display: 'block', fontSize: '12px', color: '#94a3b8', marginBottom: '8px', fontWeight: 'bold' }}>
                  Update Candidate Pipeline Stage
                </label>
                <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
                  {['APPLIED', 'UNDER_REVIEW', 'SHORTLISTED', 'ACCEPTED', 'REJECTED'].map((st) => (
                    <button
                      key={st}
                      className={selectedApp.status === st ? 'btn btn-primary' : 'btn btn-secondary'}
                      style={{ padding: '6px 12px', fontSize: '11px' }}
                      onClick={async () => {
                        await onUpdateStatus(selectedApp.id, st);
                        setSelectedApp({ ...selectedApp, status: st });
                      }}
                    >
                      {st === 'ACCEPTED' ? 'Accept / Offer' : st === 'REJECTED' ? 'Reject' : st}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            <div className="modal-footer" style={{ borderTop: '1px solid rgba(255,255,255,0.1)', paddingTop: '12px', display: 'flex', justifyContent: 'flex-end' }}>
              <button className="btn btn-secondary" onClick={() => setSelectedApp(null)}>
                Close Dossier
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

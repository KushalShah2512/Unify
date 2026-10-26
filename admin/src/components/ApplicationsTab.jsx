import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import { 
  UserCheck, 
  Briefcase, 
  Mail, 
  CheckCircle2, 
  XCircle, 
  Clock, 
  Eye, 
  X, 
  FileText, 
  Phone, 
  Award, 
  GraduationCap, 
  ShieldCheck, 
  ExternalLink 
} from 'lucide-react';

export default function ApplicationsTab({ applications, onUpdateStatus, onVerifyResume, loading }) {
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
    <>
      <div className="panel">
      <div className="panel-header">
        <div className="panel-title">
          <h2>Candidate Applications ({filtered.length})</h2>
          <p>Review student applications, verify resumes, and track recruitment pipeline</p>
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
              <th>Resume Status</th>
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
                const hasResume = !!app.student?.resumeUrl;
                const isResumeVerified = !!app.student?.isResumeVerified;

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
                      {hasResume ? (
                        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                          <span 
                            className={`badge ${isResumeVerified ? 'badge-approved' : 'badge-pending'}`}
                            style={{ display: 'inline-flex', alignItems: 'center', gap: '4px', fontSize: '11px' }}
                          >
                            <FileText size={10} />
                            {isResumeVerified ? 'Verified' : 'Pending Review'}
                          </span>
                        </div>
                      ) : (
                        <span style={{ fontSize: '11px', color: '#64748b' }}>No file</span>
                      )}
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
                            style={{ padding: '5px 8px', fontSize: '11px', color: '#818cf8', borderColor: 'rgba(99, 102, 241, 0.3)' }}
                            title="Shortlist Candidate"
                            onClick={() => onUpdateStatus(app.id, 'SHORTLISTED')}
                          >
                            Shortlist
                          </button>
                        )}

                        {app.status !== 'ACCEPTED' && (
                          <button 
                            className="btn btn-primary"
                            style={{ padding: '5px 8px', fontSize: '11px' }}
                            title="Accept / Offer"
                            onClick={() => onUpdateStatus(app.id, 'ACCEPTED')}
                          >
                            Accept
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
                  No candidate applications found for the selected filter.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>

      {/* Candidate Application & Profile Review Modal */}
      {selectedApp && typeof document !== 'undefined' && createPortal(
        <div className="modal-backdrop" onClick={() => setSelectedApp(null)}>
          <div 
            className="modal-card" 
            style={{ maxWidth: '640px' }} 
            onClick={(e) => e.stopPropagation()}
          >
            <div className="modal-header">
              <div>
                <h3 style={{ margin: 0, color: '#fff', fontSize: '18px', fontWeight: '700' }}>
                  Candidate Application Dossier
                </h3>
                <p style={{ margin: '4px 0 0 0', color: '#94a3b8', fontSize: '13px' }}>
                  Applied for <span style={{ color: '#818cf8', fontWeight: 'bold' }}>{selectedApp.opportunity?.title}</span> at {selectedApp.opportunity?.companyName}
                </p>
              </div>
              <button 
                className="icon-button"
                onClick={() => setSelectedApp(null)}
                title="Close modal"
              >
                <X size={20} />
              </button>
            </div>

            <div className="modal-body">
              {/* Candidate Info Box */}
              <div style={{ 
                background: 'rgba(30, 41, 59, 0.7)', 
                border: '1px solid rgba(255, 255, 255, 0.08)', 
                borderRadius: '12px', 
                padding: '16px', 
                marginBottom: '16px' 
              }}>
                <h4 style={{ margin: '0 0 10px 0', color: '#fff', fontSize: '16px', fontWeight: '700' }}>
                  {selectedApp.student?.fullName || 'Candidate'}
                </h4>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '10px', fontSize: '13px', color: '#cbd5e1' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <Mail size={14} color="#818cf8" /> {selectedApp.student?.user?.email || 'N/A'}
                  </div>
                  {selectedApp.student?.phoneNumber && (
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <Phone size={14} color="#818cf8" /> {selectedApp.student.phoneNumber}
                    </div>
                  )}
                  {selectedApp.student?.careerGoal && (
                    <div style={{ gridColumn: '1 / -1', color: '#94a3b8', fontSize: '12px' }}>
                      <strong style={{ color: '#e2e8f0' }}>Target Role:</strong> {selectedApp.student.careerGoal}
                    </div>
                  )}
                </div>
              </div>

              {/* Official Resume & Admin Verification Section */}
              <div style={{ 
                background: selectedApp.student?.isResumeVerified ? 'rgba(16, 185, 129, 0.08)' : 'rgba(245, 158, 11, 0.08)', 
                border: `1px solid ${selectedApp.student?.isResumeVerified ? 'rgba(16, 185, 129, 0.35)' : 'rgba(245, 158, 11, 0.35)'}`, 
                borderRadius: '12px', 
                padding: '16px', 
                marginBottom: '16px' 
              }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <FileText size={18} color={selectedApp.student?.isResumeVerified ? '#34d399' : '#fbbf24'} />
                    <strong style={{ fontSize: '14px', color: '#fff' }}>Official Master Resume</strong>
                  </div>
                  {selectedApp.student?.resumeUrl ? (
                    <span className={`badge ${selectedApp.student?.isResumeVerified ? 'badge-approved' : 'badge-pending'}`}>
                      {selectedApp.student?.isResumeVerified ? '✓ Verified by Admin' : 'Pending Verification'}
                    </span>
                  ) : (
                    <span style={{ fontSize: '12px', color: '#64748b' }}>No Resume Uploaded</span>
                  )}
                </div>

                {selectedApp.student?.resumeUrl ? (
                  <div>
                    <div style={{ fontSize: '13px', color: '#94a3b8', marginBottom: '12px' }}>
                      <span style={{ color: '#fff', fontWeight: '600' }}>
                        {selectedApp.student.resumeName || 'Candidate_Resume.pdf'}
                      </span>
                      {selectedApp.student.resumeSize && (
                        <span> • {(selectedApp.student.resumeSize / 1024).toFixed(1)} KB</span>
                      )}
                    </div>
                    
                    <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
                      <a 
                        href={selectedApp.student.resumeUrl.startsWith('http') ? selectedApp.student.resumeUrl : `http://localhost:5000${selectedApp.student.resumeUrl}`}
                        target="_blank"
                        rel="noreferrer"
                        className="btn btn-secondary"
                        style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', fontSize: '12px', padding: '8px 14px' }}
                      >
                        <ExternalLink size={14} /> View Resume Document
                      </a>

                      {onVerifyResume && selectedApp.student?.id && (
                        <button
                          className="btn"
                          style={{ 
                            fontSize: '12px', 
                            padding: '8px 14px',
                            display: 'inline-flex',
                            alignItems: 'center',
                            gap: '6px',
                            background: selectedApp.student.isResumeVerified ? 'rgba(239, 68, 68, 0.15)' : '#10b981',
                            border: `1px solid ${selectedApp.student.isResumeVerified ? '#ef4444' : '#10b981'}`,
                            color: selectedApp.student.isResumeVerified ? '#fca5a5' : '#fff',
                            fontWeight: '600',
                            cursor: 'pointer'
                          }}
                          onClick={async () => {
                            const newStatus = !selectedApp.student.isResumeVerified;
                            await onVerifyResume(selectedApp.student.id, newStatus);
                            setSelectedApp({
                              ...selectedApp,
                              student: {
                                ...selectedApp.student,
                                isResumeVerified: newStatus,
                              }
                            });
                          }}
                        >
                          <ShieldCheck size={14} />
                          {selectedApp.student.isResumeVerified ? 'Revoke Verification' : 'Verify Resume'}
                        </button>
                      )}
                    </div>
                  </div>
                ) : (
                  <p style={{ margin: 0, fontSize: '12px', color: '#94a3b8' }}>
                    Candidate has not uploaded an official master resume. Application is based on filled Career Passport profile.
                  </p>
                )}
              </div>

              {/* Cover Letter / Pitch */}
              {selectedApp.coverLetter && (
                <div style={{ 
                  background: 'rgba(99, 102, 241, 0.08)', 
                  border: '1px solid rgba(99, 102, 241, 0.25)', 
                  borderRadius: '12px', 
                  padding: '14px', 
                  marginBottom: '16px' 
                }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#818cf8', fontSize: '13px', fontWeight: '700', marginBottom: '6px' }}>
                    <FileText size={14} /> Candidate Pitch / Cover Note
                  </div>
                  <p style={{ margin: 0, fontSize: '13px', color: '#e2e8f0', lineHeight: 1.55 }}>
                    {selectedApp.coverLetter}
                  </p>
                </div>
              )}

              {/* Skills */}
              <div style={{ marginBottom: '16px' }}>
                <strong style={{ fontSize: '12px', color: '#94a3b8', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                  Verified Skills
                </strong>
                <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap', marginTop: '8px' }}>
                  {(selectedApp.student?.skills || []).map((s, idx) => (
                    <span 
                      key={idx}
                      style={{
                        background: 'rgba(99, 102, 241, 0.15)',
                        border: '1px solid rgba(99, 102, 241, 0.3)',
                        padding: '4px 10px',
                        borderRadius: '6px',
                        fontSize: '12px',
                        fontWeight: '500',
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
                <div style={{ marginBottom: '16px' }}>
                  <strong style={{ fontSize: '12px', color: '#94a3b8', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                    Education History
                  </strong>
                  <div style={{ marginTop: '8px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
                    {selectedApp.student.educationRecords.map((edu, idx) => (
                      <div key={idx} style={{ 
                        background: 'rgba(30, 41, 59, 0.5)', 
                        border: '1px solid rgba(255, 255, 255, 0.05)',
                        padding: '10px 14px', 
                        borderRadius: '8px', 
                        fontSize: '13px' 
                      }}>
                        <div style={{ fontWeight: 'bold', color: '#fff' }}>{edu.degree} - {edu.fieldOfStudy || ''}</div>
                        <div style={{ color: '#94a3b8', fontSize: '12px', marginTop: '2px' }}>{edu.institution}</div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Current Pipeline Status Selector */}
              <div style={{ 
                background: 'rgba(30, 41, 59, 0.7)', 
                border: '1px solid rgba(255, 255, 255, 0.08)', 
                borderRadius: '12px', 
                padding: '16px', 
                marginTop: '16px' 
              }}>
                <label style={{ display: 'block', fontSize: '12px', color: '#94a3b8', marginBottom: '10px', fontWeight: '700', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                  Update Candidate Pipeline Stage
                </label>
                <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
                  {['APPLIED', 'UNDER_REVIEW', 'SHORTLISTED', 'ACCEPTED', 'REJECTED'].map((st) => (
                    <button
                      key={st}
                      className={selectedApp.status === st ? 'btn btn-primary' : 'btn btn-secondary'}
                      style={{ padding: '7px 14px', fontSize: '12px' }}
                      onClick={async () => {
                        await onUpdateStatus(selectedApp.id, st);
                        setSelectedApp({ ...selectedApp, status: st });
                      }}
                    >
                      {st === 'ACCEPTED' ? 'Accept / Offer' : st === 'REJECTED' ? 'Reject' : st.replace('_', ' ')}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            <div className="modal-footer">
              <button className="btn btn-secondary" onClick={() => setSelectedApp(null)}>
                Close Dossier
              </button>
            </div>
          </div>
        </div>,
        document.body
      )}
    </>
  );
}

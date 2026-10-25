import React, { useState } from 'react';
import { Briefcase, Plus, Trash2, MapPin, DollarSign, X } from 'lucide-react';

export default function OpportunitiesTab({ opportunities, onCreate, onDelete, loading }) {
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    type: 'Internship',
    companyName: '',
    location: '',
    workMode: 'Remote',
    stipend: '',
    requiredSkills: '',
    description: '',
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    const skillsArray = formData.requiredSkills
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean);

    onCreate({
      ...formData,
      requiredSkills: skillsArray,
    });

    setShowModal(false);
    setFormData({
      title: '',
      type: 'Internship',
      companyName: '',
      location: '',
      workMode: 'Remote',
      stipend: '',
      requiredSkills: '',
      description: '',
    });
  };

  return (
    <div className="panel">
      <div className="panel-header">
        <div className="panel-title">
          <h2>Opportunity Listings ({opportunities?.length || 0})</h2>
          <p>Internships, full-time jobs, and career programs published on Unify</p>
        </div>

        <button 
          className="btn btn-primary"
          onClick={() => setShowModal(true)}
        >
          <Plus size={16} /> Add Opportunity
        </button>
      </div>

      <div className="data-table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Role / Title</th>
              <th>Company</th>
              <th>Type</th>
              <th>Mode & Location</th>
              <th>Stipend / Salary</th>
              <th>Required Skills</th>
              <th style={{ textAlign: 'right' }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="7" style={{ textAlign: 'center', padding: '36px' }}>
                  Loading opportunities...
                </td>
              </tr>
            ) : opportunities && opportunities.length > 0 ? (
              opportunities.map((opp) => (
                <tr key={opp.id}>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <Briefcase size={16} color="#818cf8" />
                      <strong style={{ color: '#fff' }}>{opp.title}</strong>
                    </div>
                  </td>
                  <td>{opp.companyName}</td>
                  <td>
                    <span 
                      className="badge" 
                      style={{ 
                        background: opp.type === 'Internship' ? 'rgba(6, 182, 212, 0.15)' : 'rgba(99, 102, 241, 0.15)',
                        color: opp.type === 'Internship' ? '#22d3ee' : '#818cf8',
                        border: '1px solid rgba(255,255,255,0.1)'
                      }}
                    >
                      {opp.type}
                    </span>
                  </td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                      <MapPin size={12} color="#64748b" />
                      <span>{opp.workMode || 'Remote'} {opp.location ? `• ${opp.location}` : ''}</span>
                    </div>
                  </td>
                  <td>{opp.stipend || opp.salary || 'Unpaid / Undisclosed'}</td>
                  <td>
                    <div style={{ display: 'flex', gap: '4px', flexWrap: 'wrap', maxWidth: '240px' }}>
                      {(opp.requiredSkills || []).slice(0, 4).map((s, idx) => (
                        <span 
                          key={idx}
                          style={{
                            background: 'rgba(255,255,255,0.06)',
                            padding: '2px 8px',
                            borderRadius: '4px',
                            fontSize: '11px',
                            color: '#cbd5e1'
                          }}
                        >
                          {s}
                        </span>
                      ))}
                      {(opp.requiredSkills || []).length > 4 && (
                        <span style={{ fontSize: '11px', color: '#64748b' }}>
                          +{(opp.requiredSkills || []).length - 4}
                        </span>
                      )}
                    </div>
                  </td>
                  <td style={{ textAlign: 'right' }}>
                    <button 
                      className="btn btn-danger"
                      style={{ padding: '6px 10px', fontSize: '12px' }}
                      onClick={() => onDelete(opp.id)}
                      title="Delete opportunity"
                    >
                      <Trash2 size={14} />
                    </button>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="7" style={{ textAlign: 'center', padding: '36px' }}>
                  No opportunities currently created. Click "Add Opportunity" above.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Modal for creating opportunity */}
      {showModal && (
        <div className="modal-backdrop" onClick={() => setShowModal(false)}>
          <div className="modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3 style={{ color: '#fff', fontSize: '18px', fontWeight: '700' }}>
                Add New Career Opportunity
              </h3>
              <button 
                onClick={() => setShowModal(false)}
                style={{ background: 'none', border: 'none', color: '#64748b', cursor: 'pointer' }}
              >
                <X size={20} />
              </button>
            </div>

            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-group">
                  <label>Position / Role Title *</label>
                  <input 
                    type="text" 
                    className="form-control"
                    placeholder="e.g. Frontend Developer Intern"
                    required
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  />
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                  <div className="form-group">
                    <label>Hiring Organization *</label>
                    <input 
                      type="text" 
                      className="form-control"
                      placeholder="e.g. Google / Microsoft"
                      required
                      value={formData.companyName}
                      onChange={(e) => setFormData({ ...formData, companyName: e.target.value })}
                    />
                  </div>

                  <div className="form-group">
                    <label>Opportunity Type</label>
                    <select 
                      className="form-control"
                      value={formData.type}
                      onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                    >
                      <option value="Internship">Internship</option>
                      <option value="Full-time">Full-time Job</option>
                      <option value="Part-time">Part-time Job</option>
                      <option value="Fellowship">Fellowship</option>
                    </select>
                  </div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                  <div className="form-group">
                    <label>Work Mode</label>
                    <select 
                      className="form-control"
                      value={formData.workMode}
                      onChange={(e) => setFormData({ ...formData, workMode: e.target.value })}
                    >
                      <option value="Remote">Remote</option>
                      <option value="Hybrid">Hybrid</option>
                      <option value="Onsite">Onsite</option>
                    </select>
                  </div>

                  <div className="form-group">
                    <label>Location</label>
                    <input 
                      type="text" 
                      className="form-control"
                      placeholder="e.g. Pune, MH / Bengaluru"
                      value={formData.location}
                      onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                    />
                  </div>
                </div>

                <div className="form-group">
                  <label>Salary / Stipend</label>
                  <input 
                    type="text" 
                    className="form-control"
                    placeholder="e.g. ₹25,000 / month or ₹8-12 LPA"
                    value={formData.stipend}
                    onChange={(e) => setFormData({ ...formData, stipend: e.target.value })}
                  />
                </div>

                <div className="form-group">
                  <label>Required Skills (comma separated) *</label>
                  <input 
                    type="text" 
                    className="form-control"
                    placeholder="e.g. React, JavaScript, CSS, Git"
                    required
                    value={formData.requiredSkills}
                    onChange={(e) => setFormData({ ...formData, requiredSkills: e.target.value })}
                  />
                </div>

                <div className="form-group">
                  <label>Role Description</label>
                  <textarea 
                    className="form-control"
                    rows="3"
                    placeholder="Describe responsibilities and candidate qualifications..."
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  ></textarea>
                </div>
              </div>

              <div style={{ padding: '16px 24px', borderTop: '1px solid var(--border-subtle)', display: 'flex', justifyContent: 'flex-end', gap: '12px' }}>
                <button 
                  type="button" 
                  className="btn btn-secondary"
                  onClick={() => setShowModal(false)}
                >
                  Cancel
                </button>
                <button 
                  type="submit" 
                  className="btn btn-primary"
                >
                  Publish Opportunity
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

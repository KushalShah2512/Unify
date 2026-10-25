import React, { useState } from 'react';
import { Search, UserCheck, Shield, GraduationCap, Building2 } from 'lucide-react';

export default function UsersTab({ users, loading }) {
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('ALL');

  const filteredUsers = (users || []).filter((u) => {
    const matchesRole = roleFilter === 'ALL' || u.role === roleFilter;
    const name = u.studentProfile?.fullName || u.employerProfile?.companyName || '';
    const matchesSearch = 
      u.email.toLowerCase().includes(search.toLowerCase()) ||
      name.toLowerCase().includes(search.toLowerCase());
    return matchesRole && matchesSearch;
  });

  return (
    <div className="panel">
      <div className="panel-header">
        <div className="panel-title">
          <h2>Users Directory ({filteredUsers.length})</h2>
          <p>Search, filter, and view user details across roles</p>
        </div>

        <div className="table-controls">
          <div className="search-box">
            <Search size={16} />
            <input 
              type="text" 
              placeholder="Search by email or name..." 
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>

          <select 
            className="custom-select"
            value={roleFilter}
            onChange={(e) => setRoleFilter(e.target.value)}
          >
            <option value="ALL">All Roles</option>
            <option value="STUDENT">Students</option>
            <option value="EMPLOYER">Employers</option>
            <option value="ADMIN">Admins</option>
          </select>
        </div>
      </div>

      <div className="data-table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>User</th>
              <th>Role</th>
              <th>Profile Name</th>
              <th>Details / Location</th>
              <th>Created At</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '36px' }}>
                  Loading users...
                </td>
              </tr>
            ) : filteredUsers.length > 0 ? (
              filteredUsers.map((u) => {
                const isStudent = u.role === 'STUDENT';
                const isEmployer = u.role === 'EMPLOYER';
                const isAdmin = u.role === 'ADMIN';

                const roleClass = isStudent ? 'badge-student' : isEmployer ? 'badge-employer' : 'badge-admin';
                const profileTitle = isStudent 
                  ? u.studentProfile?.fullName || 'Not Profiled'
                  : isEmployer 
                  ? u.employerProfile?.companyName || 'Not Profiled'
                  : 'System Administrator';

                const details = isStudent 
                  ? (u.studentProfile?.education || u.studentProfile?.location || '—')
                  : isEmployer 
                  ? `${u.employerProfile?.industry || 'Industry'} (${u.employerProfile?.verificationStatus})`
                  : 'Full Access';

                return (
                  <tr key={u.id}>
                    <td>#{u.id}</td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        {isStudent && <GraduationCap size={16} color="#60a5fa" />}
                        {isEmployer && <Building2 size={16} color="#c084fc" />}
                        {isAdmin && <Shield size={16} color="#fbbf24" />}
                        <strong style={{ color: '#fff' }}>{u.email}</strong>
                      </div>
                    </td>
                    <td>
                      <span className={`badge ${roleClass}`}>{u.role}</span>
                    </td>
                    <td>{profileTitle}</td>
                    <td>{details}</td>
                    <td>{new Date(u.createdAt).toLocaleDateString()}</td>
                  </tr>
                );
              })
            ) : (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '36px' }}>
                  No users found matching current filters.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

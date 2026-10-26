import { 
  LayoutDashboard, 
  Users, 
  Building2, 
  Briefcase, 
  LogOut, 
  ShieldCheck,
  AlertTriangle
} from 'lucide-react';

export default function Sidebar({ activeTab, setActiveTab, pendingCount, reportsCount, user, onLogout }) {
  const navItems = [
    { id: 'overview', label: 'Overview', icon: LayoutDashboard },
    { id: 'users', label: 'Users Management', icon: Users },
    { 
      id: 'employers', 
      label: 'Employer Verifications', 
      icon: Building2, 
      badge: pendingCount > 0 ? pendingCount : null 
    },
    { id: 'opportunities', label: 'Opportunities', icon: Briefcase },
    { id: 'applications', label: 'Candidate Applications', icon: ShieldCheck },
    { 
      id: 'moderation', 
      label: 'Safety Moderation', 
      icon: AlertTriangle, 
      badge: reportsCount > 0 ? reportsCount : null 
    },
  ];

  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <img 
          src="/logo.png" 
          alt="Unify" 
          style={{ width: '38px', height: '38px', borderRadius: '8px', objectFit: 'cover' }} 
        />
        <div className="brand-info">
          <h1>Unify</h1>
          <span>Admin Console</span>
        </div>
      </div>

      <nav className="sidebar-nav">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;
          return (
            <button
              key={item.id}
              className={`nav-item ${isActive ? 'active' : ''}`}
              onClick={() => setActiveTab(item.id)}
            >
              <Icon size={18} />
              <span>{item.label}</span>
              {item.badge && <span className="nav-badge">{item.badge}</span>}
            </button>
          );
        })}
      </nav>

      <div className="sidebar-footer">
        <div className="admin-profile">
          <div className="admin-avatar">
            <ShieldCheck size={20} />
          </div>
          <div className="admin-meta">
            <div className="name">{user?.email?.split('@')[0] || 'Admin'}</div>
            <div className="role">Administrator</div>
          </div>
        </div>
        <button 
          className="logout-btn" 
          onClick={onLogout}
          title="Sign out of Admin Console"
        >
          <LogOut size={18} />
        </button>
      </div>
    </aside>
  );
}

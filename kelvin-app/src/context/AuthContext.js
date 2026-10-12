import React, { createContext, useContext, useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

const AuthContext = createContext(null);

const DEMO_USERS = [
  { email: 'suresh@kelvinmech.com',  password: 'kelvin123', name: 'Suresh Iyer',  role: 'Procurement Manager', avatar: 'SI' },
  { email: 'priya@kelvinmech.com',   password: 'kelvin123', name: 'Priya Shah',    role: 'Project Manager',     avatar: 'PS' },
  { email: 'admin@kelvinmech.com',   password: 'admin123',  name: 'Sachin G',      role: 'Admin / Architect',   avatar: 'SG' },
  { email: 'demo@kelvinmech.com',    password: 'demo',      name: 'Demo User',     role: 'Viewer',              avatar: 'DU' },
];

export function AuthProvider({ children }) {
  const [user, setUser]       = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    AsyncStorage.getItem('km_user').then(val => {
      if (val) setUser(JSON.parse(val));
      setLoading(false);
    });
  }, []);

  const login = async (email, password) => {
    const demo = DEMO_USERS.find(u => u.email === email && u.password === password);
    if (demo) {
      const u = { id: 'u1', name: demo.name, email: demo.email, role: demo.role, avatar: demo.avatar };
      await AsyncStorage.setItem('km_user', JSON.stringify(u));
      setUser(u);
      return { ok: true };
    }
    return { ok: false, error: 'Invalid credentials' };
  };

  const loginWithGoogle = async () => {
    const u = { id: 'g1', name: 'Suresh Iyer', email: 'suresh@kelvinmech.com', role: 'Procurement Manager', avatar: 'SI', googleAuth: true };
    await AsyncStorage.setItem('km_user', JSON.stringify(u));
    setUser(u);
    return { ok: true };
  };

  const logout = async () => {
    await AsyncStorage.removeItem('km_user');
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, loading, login, loginWithGoogle, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);

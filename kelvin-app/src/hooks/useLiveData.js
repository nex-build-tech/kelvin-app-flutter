import { useState, useEffect, useRef } from 'react';

const clamp   = (v, min, max) => Math.min(Math.max(v, min), max);
const randInt = (min, max)    => Math.floor(Math.random() * (max - min + 1)) + min;

export function useLiveKpis(initial) {
  const [kpis, setKpis] = useState(initial);
  useEffect(() => {
    const id = setInterval(() => {
      setKpis(prev => ({
        tasks:     clamp(prev.tasks     + randInt(-1, 2), 8,  18),
        breaches:  clamp(prev.breaches  + randInt(-1, 1), 1,  6),
        approvals: clamp(prev.approvals + randInt(-1, 1), 2,  7),
        enquiries: clamp(prev.enquiries + randInt(-1, 2), 4,  12),
      }));
    }, 3000);
    return () => clearInterval(id);
  }, []);
  return kpis;
}

export function useLiveProjects(initial) {
  const [projects, setProjects] = useState(initial);
  useEffect(() => {
    const id = setInterval(() => {
      setProjects(prev => {
        const idx = randInt(0, prev.length - 1);
        return prev.map((p, i) =>
          i === idx ? { ...p, pct: clamp(p.pct + randInt(0, 1), p.pct, Math.min(p.pct + 2, 99)) } : p
        );
      });
    }, 5000);
    return () => clearInterval(id);
  }, []);
  return projects;
}

export function useLiveFeed(initial, pool) {
  const [feed, setFeed] = useState(initial);
  const poolRef = useRef(0);
  useEffect(() => {
    const id = setInterval(() => {
      const next = pool[poolRef.current % pool.length];
      poolRef.current++;
      setFeed(prev => [{ ...next, id: Date.now(), isNew: true }, ...prev.slice(0, 12)]);
    }, 6000);
    return () => clearInterval(id);
  }, []);
  return feed;
}

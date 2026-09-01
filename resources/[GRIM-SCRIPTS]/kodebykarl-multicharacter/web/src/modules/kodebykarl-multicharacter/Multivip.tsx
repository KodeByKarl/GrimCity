import React, { useEffect, useMemo, useState } from 'react';
import { Crown, Search, Shield, Users, X } from 'lucide-react';

export interface MultivipPlayer {
  id: number;
  name: string;
  identifier: string;
  slots: number;
  online?: boolean;
  grantedBy?: string;
}

export interface MultivipData {
  staffName?: string;
  staffGroup?: string;
  players?: MultivipPlayer[];
}

interface MultivipProps {
  data: MultivipData | null;
  onClose: () => void;
}

function resourceName() {
  return (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : 'kodebykarl-multicharacter';
}

function fetchNui(event: string, payload?: unknown) {
  return fetch(`https://${resourceName()}/${event}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload ?? {}),
  }).then((res) => res.json()).catch(() => null);
}

const SLOT_OPTIONS = [1, 2, 3];

const Multivip: React.FC<MultivipProps> = ({ data, onClose }) => {
  const [players, setPlayers] = useState<MultivipPlayer[]>(data?.players ?? []);
  const [search, setSearch] = useState('');
  const [busyId, setBusyId] = useState<string | null>(null);

  useEffect(() => {
    setPlayers(data?.players ?? []);
  }, [data]);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [onClose]);

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return players;
    return players.filter((player) =>
      [player.name, String(player.id), player.identifier]
        .some((value) => value.toLowerCase().includes(q))
    );
  }, [players, search]);

  const setSlots = async (player: MultivipPlayer, slots: number) => {
    if (busyId !== null || player.slots === slots) return;
    setBusyId(player.identifier);
    const result = await fetchNui('setMultivipSlots', {
      serverId: player.id,
      identifier: player.identifier,
      name: player.name,
      slots,
    });
    if (result?.ok && result.players) {
      setPlayers(result.players);
    }
    setBusyId(null);
  };

  return (
    <div className="multivip-overlay">
      <div className="multivip-panel">
        <header className="multivip-header">
          <div>
            <div className="brand-badge">GRIM CITY ROLEPLAY</div>
            <h1>MULTIVIP SLOT ACCESS</h1>
            <span className="dev-tag">
              Staff: <strong>{data?.staffName || 'Unknown'}</strong>
              {data?.staffGroup ? ` · ${data.staffGroup.toUpperCase()}` : ''}
            </span>
          </div>
          <button type="button" className="multivip-close" onClick={onClose}>
            <X size={18} />
          </button>
        </header>

        <p className="multivip-copy">
          Slot access is saved in the database. Online players and previously granted VIP accounts stay on this list after restart.
        </p>

        <div className="multivip-search">
          <Search size={16} />
          <input
            type="text"
            placeholder="Search name, ID, or license..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>

        <div className="multivip-list">
          {filtered.length === 0 ? (
            <div className="multivip-empty">
              <Users size={22} />
              <span>No online players match that search.</span>
            </div>
          ) : (
            filtered.map((player) => (
              <div key={player.identifier} className="multivip-row">
                <div className="multivip-identity">
                  <div className="multivip-avatar">
                    {player.slots > 1 ? <Crown size={16} /> : <Shield size={16} />}
                  </div>
                  <div>
                    <h3>{player.name}</h3>
                    <span>
                      {player.online ? `ID ${player.id}` : 'SAVED'} · {player.slots} SLOT{player.slots === 1 ? '' : 'S'}
                      {player.grantedBy ? ` · by ${player.grantedBy}` : ''}
                    </span>
                  </div>
                </div>
                <div className="multivip-actions">
                  {SLOT_OPTIONS.map((slots) => (
                    <button
                      key={slots}
                      type="button"
                      className={`multivip-slot-btn ${player.slots === slots ? 'active' : ''} ${slots > 1 ? 'vip' : ''}`}
                      disabled={busyId === player.identifier}
                      onClick={() => setSlots(player, slots)}
                    >
                      {slots === 1 ? 'NONE' : `SLOT ${slots}`}
                    </button>
                  ))}
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};

export default Multivip;

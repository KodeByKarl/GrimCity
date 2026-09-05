import React, { useState, useEffect, useRef } from 'react';
import { Play, Trash2, Plus, UserCheck, Shield, DollarSign, Calendar, User, Ruler, ChevronDown, AlertTriangle, Lock, Crown } from 'lucide-react';

export interface Character {
  id: number;
  identifier?: string;
  firstname: string;
  lastname: string;
  dateofbirth: string;
  sex: string;
  rawSex?: string;
  height: number;
  job: string;
  job_grade?: number;
  money: number;
  bank: number;
  skin?: any;
}

export interface ExtendedCharacter extends Character {
  skin?: any;
}

interface MulticharacterProps {
  characters: ExtendedCharacter[];
  maxSlots: number;
  onClose: () => void;
}

interface CustomSelectProps {
  value: string;
  options: { label: string; value: string }[];
  onChange: (val: string) => void;
}

const CustomSelect: React.FC<CustomSelectProps> = ({ value, options, onChange }) => {
  const [isOpen, setIsOpen] = useState(false);
  const selectedOption = options.find((o) => o.value === value) || options[0];

  return (
    <div className="custom-select-container">
      <div className="custom-select-header" onClick={() => setIsOpen(!isOpen)}>
        <span>{selectedOption.label}</span>
        <ChevronDown size={16} className={`select-arrow ${isOpen ? 'open' : ''}`} />
      </div>
      {isOpen && (
        <div className="custom-select-dropdown">
          {options.map((opt) => (
            <div
              key={opt.value}
              className={`custom-option ${opt.value === value ? 'selected' : ''}`}
              onClick={() => {
                onChange(opt.value);
                setIsOpen(false);
              }}
            >
              {opt.label}
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

const TOTAL_SLOTS = 3;

const Multicharacter: React.FC<MulticharacterProps> = ({ characters, maxSlots = 1, onClose }) => {
  const [selectedChar, setSelectedChar] = useState<ExtendedCharacter | null>(null);
  const [showCreateModal, setShowCreateModal] = useState<boolean>(false);
  const [showDeleteModal, setShowDeleteModal] = useState<boolean>(false);
  const [formData, setFormData] = useState({
    firstname: '',
    lastname: '',
    dateofbirth: '2005-01-01',
    sex: 'm',
    height: 175,
  });
  const didAutoPreview = useRef(false);

  const allowedSlots = Math.max(1, Math.min(maxSlots, TOTAL_SLOTS));
  const isExpanded = selectedChar !== null;

  const nui = (event: string, payload?: unknown) => {
    fetch(`https://${(window as any).GetParentResourceName ? (window as any).GetParentResourceName() : 'kodebykarl-multicharacter'}/${event}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload ?? {}),
    }).catch(() => {});
  };

  const handleSelectChar = (char: ExtendedCharacter) => {
    setSelectedChar(char);
    nui('previewCharacter', { skin: char.skin, rawSex: char.rawSex, sex: char.sex });
  };

  // Auto-select + preview first character as soon as the UI opens
  useEffect(() => {
    if (didAutoPreview.current) return;
    if (!characters || characters.length === 0) return;
    didAutoPreview.current = true;
    handleSelectChar(characters[0]);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [characters]);

  const handleLockedSlot = (slotNumber: number) => {
    nui('vipSlotLocked', { slot: slotNumber });
  };

  const handlePlay = () => {
    if (!selectedChar) return;
    nui('selectCharacter', { charId: selectedChar.id });
    onClose();
  };

  const confirmDeleteCharacter = () => {
    if (!selectedChar) return;
    nui('deleteCharacter', { charId: selectedChar.id });
    setSelectedChar(null);
    setShowDeleteModal(false);
    nui('previewCharacter', { clearPreview: true });
  };

  const handleCreateSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    nui('createCharacter', formData);
    setShowCreateModal(false);
    onClose();
  };

  return (
    <div className={`multichar-viewport ${isExpanded ? 'is-expanded' : 'is-centered'}`}>
      <div className="panel-left">
        <div className="slots-container-box">
          <header className="brand-header">
            <div className="brand-badge">GRIM CITY ROLEPLAY</div>
            <h1>CHARACTER SELECTION</h1>
            <span className="dev-tag">Powered by <strong>KodeByKarl.Net</strong></span>
          </header>

          <div className="slots-list">
            {Array.from({ length: TOTAL_SLOTS }).map((_, index) => {
              const char = characters[index];
              const isSelected = selectedChar?.id === char?.id;
              const isLocked = !char && index >= allowedSlots;

              if (char) {
                return (
                  <div
                    key={char.id}
                    className={`slot-item ${isSelected ? 'active' : ''}`}
                    onClick={() => handleSelectChar(char)}
                  >
                    <div className="slot-badge">SLOT #{index + 1}</div>
                    <div className="slot-info">
                      <h3>{char.firstname} {char.lastname}</h3>
                      <span>{char.job.toUpperCase()}</span>
                    </div>
                  </div>
                );
              }

              if (isLocked) {
                return (
                  <div
                    key={index}
                    className="slot-item locked"
                    onClick={() => handleLockedSlot(index + 1)}
                  >
                    <div className="slot-badge">SLOT #{index + 1}</div>
                    <div className="slot-info create-info">
                      <Lock size={16} />
                      <span>VIP REQUIRED</span>
                      <Crown size={14} />
                    </div>
                  </div>
                );
              }

              return (
                <div
                  key={index}
                  className="slot-item empty"
                  onClick={() => setShowCreateModal(true)}
                >
                  <div className="slot-badge">SLOT #{index + 1}</div>
                  <div className="slot-info create-info">
                    <Plus size={18} />
                    <span>CREATE CHARACTER</span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Center Viewport (Transparent Frame for 3D Ped Preview) */}
      <div className="viewport-center" />

      {/* Right Panel Container Box */}
      <div className={`panel-right ${selectedChar ? 'visible' : ''}`}>
        {selectedChar && (
          <div className="details-box">
            <div className="details-header">
              <span className="sub-title">CHARACTER PROFILE</span>
              <h2>{selectedChar.firstname.toUpperCase()} {selectedChar.lastname.toUpperCase()}</h2>
            </div>

            <div className="info-grid">
              <div className="info-item">
                <Shield size={18} className="info-icon" />
                <div className="info-text">
                  <span className="label">JOB / OCCUPATION</span>
                  <span className="val">{selectedChar.job.toUpperCase()}</span>
                </div>
              </div>

              <div className="info-item">
                <DollarSign size={18} className="info-icon" />
                <div className="info-text">
                  <span className="label">CASH BALANCE</span>
                  <span className="val">${selectedChar.money.toLocaleString()}</span>
                </div>
              </div>

              <div className="info-item">
                <DollarSign size={18} className="info-icon" />
                <div className="info-text">
                  <span className="label">BANK BALANCE</span>
                  <span className="val">${selectedChar.bank.toLocaleString()}</span>
                </div>
              </div>

              <div className="info-item">
                <Calendar size={18} className="info-icon" />
                <div className="info-text">
                  <span className="label">DATE OF BIRTH</span>
                  <span className="val">{selectedChar.dateofbirth}</span>
                </div>
              </div>

              <div className="info-item">
                <User size={18} className="info-icon" />
                <div className="info-text">
                  <span className="label">GENDER</span>
                  <span className="val">{selectedChar.sex.toUpperCase()}</span>
                </div>
              </div>

              <div className="info-item">
                <Ruler size={18} className="info-icon" />
                <div className="info-text">
                  <span className="label">HEIGHT</span>
                  <span className="val">{selectedChar.height} CM</span>
                </div>
              </div>
            </div>

            <div className="actions-group">
              <button className="btn btn-spawn" onClick={handlePlay}>
                <Play size={18} /> PLAY CHARACTER
              </button>
              <button className="btn btn-delete" onClick={() => setShowDeleteModal(true)}>
                <Trash2 size={18} /> DELETE
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Delete Confirmation Modal */}
      {showDeleteModal && selectedChar && (
        <div className="modal-overlay">
          <div className="create-modal delete-modal">
            <div className="modal-header">
              <div className="delete-warning-icon">
                <AlertTriangle size={32} />
              </div>
              <h2>CONFIRM CHARACTER DELETION</h2>
              <span className="modal-subtitle">PERMANENT ACTION - CANNOT BE UNDONE</span>
            </div>

            <div className="delete-body-text">
              <p>Are you sure you want to delete <strong>{selectedChar.firstname} {selectedChar.lastname}</strong>?</p>
              <p className="sub-warning">All inventory items, bank balance, property, and character progress will be permanently erased from Grim City Roleplay database.</p>
            </div>

            <div className="modal-buttons">
              <button type="button" className="btn btn-delete" onClick={confirmDeleteCharacter}>
                <Trash2 size={18} /> DELETE PERMANENTLY
              </button>
              <button
                type="button"
                className="btn btn-cancel"
                onClick={() => setShowDeleteModal(false)}
              >
                CANCEL
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Create Character Modal */}
      {showCreateModal && (
        <div className="modal-overlay">
          <div className="create-modal">
            <div className="modal-header">
              <h2>CREATE NEW CHARACTER</h2>
              <span className="modal-subtitle">Grim City Roleplay Identity Registration</span>
            </div>

            <form onSubmit={handleCreateSubmit}>
              <div className="form-group">
                <label>FIRST NAME</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Karl"
                  value={formData.firstname}
                  onChange={(e) => setFormData({ ...formData, firstname: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>LAST NAME</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Dev"
                  value={formData.lastname}
                  onChange={(e) => setFormData({ ...formData, lastname: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>DATE OF BIRTH (YYYY-MM-DD)</label>
                <input
                  type="text"
                  required
                  placeholder="2005-01-01"
                  maxLength={10}
                  value={formData.dateofbirth}
                  onChange={(e) => setFormData({ ...formData, dateofbirth: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>GENDER</label>
                <CustomSelect
                  value={formData.sex}
                  options={[
                    { label: 'Male', value: 'm' },
                    { label: 'Female', value: 'f' },
                  ]}
                  onChange={(val) => setFormData({ ...formData, sex: val })}
                />
              </div>

              <div className="form-group">
                <label>HEIGHT (CM)</label>
                <input
                  type="number"
                  min="140"
                  max="210"
                  value={formData.height}
                  onChange={(e) => setFormData({ ...formData, height: parseInt(e.target.value) || 175 })}
                />
              </div>

              <div className="modal-buttons">
                <button type="submit" className="btn btn-spawn">
                  <UserCheck size={18} /> SPAWN CHARACTER
                </button>
                <button
                  type="button"
                  className="btn btn-cancel"
                  onClick={() => setShowCreateModal(false)}
                >
                  CANCEL
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Multicharacter;

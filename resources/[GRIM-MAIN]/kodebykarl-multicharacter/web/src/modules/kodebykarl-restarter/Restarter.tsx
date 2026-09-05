import React, { useState, useEffect } from 'react';
import { AlertTriangle, Clock, ShieldAlert } from 'lucide-react';

interface RestarterProps {
  duration: number; // in seconds
  reason: string;
  onFinished?: () => void;
}

const Restarter: React.FC<RestarterProps> = ({ duration, reason, onFinished }) => {
  const [timeLeft, setTimeLeft] = useState<number>(duration);
  const totalDuration = duration > 0 ? duration : 300;

  useEffect(() => {
    setTimeLeft(duration);
  }, [duration]);

  useEffect(() => {
    if (timeLeft <= 0) {
      if (onFinished) onFinished();
      return;
    }

    const timer = setInterval(() => {
      setTimeLeft((prev) => prev - 1);
    }, 1000);

    return () => clearInterval(timer);
  }, [timeLeft, onFinished]);

  const minutes = Math.floor(Math.max(0, timeLeft) / 60);
  const seconds = Math.max(0, timeLeft) % 60;
  const formattedTime = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  const progressPercent = Math.min(100, Math.max(0, (timeLeft / totalDuration) * 100));

  const isCritical = timeLeft <= 60;
  const isEmergency = timeLeft <= 10;

  return (
    <div className={`restarter-overlay ${isEmergency ? 'pulse-emergency' : ''}`}>
      <div className="restarter-card">
        <div className="restarter-header">
          <AlertTriangle size={28} className="warning-icon" />
          <div className="title-group">
            <span className="badge-warning">GRIM SCHOOL RP SERVER EVENT</span>
            <h2>SERVER RESTART IMMINENT</h2>
          </div>
        </div>

        <div className="restarter-timer-box">
          <div className="timer-display">
            <Clock size={36} style={{ color: isCritical ? '#ff3b3b' : '#ffb703' }} />
            <span className={`time-text ${isCritical ? 'critical-glow' : ''}`}>{formattedTime}</span>
          </div>
          <div className="progress-track">
            <div
              className={`progress-fill ${isCritical ? 'bg-danger' : 'bg-warning'}`}
              style={{ width: `${progressPercent}%` }}
            />
          </div>
        </div>

        <div className="restarter-footer">
          <div className="reason-box">
            <ShieldAlert size={18} style={{ minWidth: '18px' }} />
            <span>Reason: <strong>{reason}</strong></span>
          </div>
          <p className="notice-text">Please park vehicles and log off to prevent data loss.</p>
        </div>
      </div>
    </div>
  );
};

export default Restarter;

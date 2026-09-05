import { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { onNuiEvent } from './utils/onNui';
import VitalsMonitor, { type VitalsData } from './VitalsMonitor';

import './index.css';

function App() {
    const [isDead, setIsDead] = useState(false);
    const [timer, setTimer] = useState(300);
    const [isBleedout, setIsBleedout] = useState(false);
    const [_dispatched, setDispatched] = useState(false);
    const [freecam, setFreecam] = useState(false);
    const [vitals, setVitals] = useState<VitalsData | null>(null);

    const formatTime = (seconds: number) => {
        const mins = Math.floor(seconds / 60);
        const secs = seconds % 60;
        return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
    };

    useEffect(() => {
        onNuiEvent('ShowUI', (data) => {
            setIsDead(true);
            setIsBleedout(false);
            setDispatched(false);
            setFreecam(false);
            if (data?.time) setTimer(data.time);
        });

        onNuiEvent('HideUI', () => {
            setIsDead(false);
            setFreecam(false);
        });

        onNuiEvent('updateDeathScreen', (data) => {
            if (data.update === 'text') {
                setIsBleedout(!!data.bleedout);
            }
            if (data.update === 'time' && data.time >= 0) {
                setTimer(data.time);
            }
            if (data.update === 'dispatch') {
                setDispatched(!!data.dispatched);
            }
            if (data.update === 'freecam') {
                setFreecam(!!data.freecam);
            }
        });

        onNuiEvent('ShowVitals', (data) => {
            setVitals(data as VitalsData);
        });

        onNuiEvent('HideVitals', () => {
            setVitals(null);
        });
    }, []);

    return (
        <>
            <AnimatePresence>
                {isDead && (
                    <div className="death-screen-wrapper">
                        <motion.div
                            className="death-bar-container"
                            initial={{ opacity: 0, y: 25 }}
                            animate={{ opacity: 1, y: 0 }}
                            exit={{ opacity: 0, y: 25 }}
                            transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
                        >
                            <div className="accent-line" />

                            <div className="logo-badge">
                                <img src="./logo.png" alt="logo" className="logo-img" />
                            </div>

                            <div className="title-group">
                                <span className="subtitle">{isBleedout ? 'BLEEDOUT' : 'DEATH CAM'}</span>
                                <h1 className="main-title">{isBleedout ? 'Critical Condition' : 'Incapacitated'}</h1>
                            </div>

                            <div className="timer-badge">
                                <svg className="clock-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                                    <circle cx="12" cy="12" r="10" />
                                    <polyline points="12 6 12 12 16 14" />
                                </svg>
                                <span className="timer-text">{formatTime(timer)}</span>
                            </div>

                            <div className={`action-pill ${freecam ? 'is-active' : ''}`}>
                                <div className="key-box">G</div>
                                <div className="label-box">{freecam ? 'Exit Freecam' : 'Freecam'}</div>
                            </div>
                            <div className="action-pill">
                                <div className="key-box">{isBleedout ? 'E' : 'H'}</div>
                                <div className="label-box">
                                    {isBleedout ? 'Hold to Respawn' : 'Select Spawn Location'}
                                </div>
                            </div>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>

            <AnimatePresence>
                {vitals && <VitalsMonitor key="vitals-monitor" data={vitals} />}
            </AnimatePresence>
        </>
    );
}

export default App;

import { useEffect, useMemo, useState } from 'react';
import { motion } from 'framer-motion';

export type Injury = {
    label: string;
    severity: number;
    wound: string;
};

export type VitalsData = {
    name?: string;
    sid?: number;
    dead?: boolean;
    status?: string;
    hr?: number;
    hrStatus?: string;
    rhythm?: string;
    bpSys?: number;
    bpDia?: number;
    bpStatus?: string;
    spo2?: number;
    spo2Status?: string;
    rr?: number;
    rrStatus?: string;
    temp?: number;
    blood?: number;
    bloodStatus?: string;
    bleeding?: string;
    bleedLevel?: number;
    consciousness?: string;
    gcs?: number;
    injuries?: Injury[];
    area?: string;
    armor?: number;
    health?: number;
    duration?: number;
};

const ECG_PATH =
    'M0 40 H18 L22 40 L26 28 L30 52 L34 18 L38 62 L42 40 H62 L66 34 L70 40 H100';

function tone(status?: string) {
    const s = (status || '').toLowerCase();
    if (s.includes('critical') || s.includes('deceas') || s.includes('asyst') || s.includes('low') || s.includes('severe') || s.includes('high')) {
        if (s.includes('deceas') || s.includes('asyst') || s.includes('critical') || s.includes('severe')) return 'bad';
        return 'warn';
    }
    if (s.includes('unstable') || s.includes('moderate') || s.includes('tach') || s.includes('brady')) return 'warn';
    return 'ok';
}

function VitalCell({
    label,
    value,
    unit,
    status,
    large,
}: {
    label: string;
    value: string | number;
    unit?: string;
    status?: string;
    large?: boolean;
}) {
    return (
        <div className={`vm-cell ${tone(status)}`}>
            <div className="vm-cell-label">{label}</div>
            <div className={`vm-cell-value ${large ? 'lg' : ''}`}>
                {value}
                {unit ? <span className="vm-unit">{unit}</span> : null}
            </div>
            {status ? <div className="vm-cell-status">{status}</div> : null}
        </div>
    );
}

export default function VitalsMonitor({ data }: { data: VitalsData }) {
    const [remain, setRemain] = useState(data.duration || 12);
    const hr = Math.max(0, Number(data.hr) || 0);
    const dead = !!data.dead || hr <= 0;
    const durationSec = Math.max(0.45, 60 / Math.max(hr, 48));

    useEffect(() => {
        setRemain(data.duration || 12);
        const id = window.setInterval(() => {
            setRemain((v) => Math.max(0, v - 1));
        }, 1000);
        return () => window.clearInterval(id);
    }, [data]);

    const injuries = Array.isArray(data.injuries) ? data.injuries : [];
    const status = data.status || (dead ? 'DECEASED' : 'STABLE');
    const ecgCopies = useMemo(() => Array.from({ length: 8 }, (_, i) => i), []);

    return (
        <div className="vitals-wrapper">
            <motion.div
                className={`vitals-monitor ${dead ? 'is-dead' : ''}`}
                initial={{ opacity: 0, x: 28, scale: 0.98 }}
                animate={{ opacity: 1, x: 0, scale: 1 }}
                exit={{ opacity: 0, x: 28, scale: 0.98 }}
                transition={{ duration: 0.28, ease: [0.16, 1, 0.3, 1] }}
            >
                <header className="vm-header">
                    <div className="vm-brand">
                        <span className="vm-dot" />
                        <span>PANDORA EMS</span>
                    </div>
                    <div className="vm-title">Patient Monitor</div>
                    <div className="vm-clock">LIVE · {remain}s</div>
                </header>

                <div className="vm-patient">
                    <div>
                        <div className="vm-name">{data.name || 'Unknown patient'}</div>
                        <div className="vm-meta">
                            ID {data.sid ?? '—'} · GCS {data.gcs ?? '—'} {data.consciousness || ''}
                        </div>
                    </div>
                    <div className={`vm-badge ${tone(status)}`}>{status}</div>
                </div>

                <div className="vm-ecg">
                    <div className="vm-ecg-label">II</div>
                    <div className="vm-ecg-track">
                        <svg viewBox="0 0 800 80" preserveAspectRatio="none" className={dead ? 'flat' : ''}>
                            {dead ? (
                                <line x1="0" y1="40" x2="800" y2="40" />
                            ) : (
                                <g
                                    className="vm-ecg-wave"
                                    style={{ animationDuration: `${durationSec}s` }}
                                >
                                    {ecgCopies.map((i) => (
                                        <path key={i} d={ECG_PATH} transform={`translate(${i * 100} 0)`} />
                                    ))}
                                </g>
                            )}
                        </svg>
                    </div>
                    <div className="vm-hr-block">
                        <div className="vm-cell-label">HR</div>
                        <div className={`vm-hr ${tone(data.hrStatus)}`}>{hr}</div>
                        <div className="vm-unit">BPM</div>
                    </div>
                </div>

                <div className="vm-grid">
                    <VitalCell
                        label="NIBP"
                        value={dead ? '— / —' : `${data.bpSys ?? 0}/${data.bpDia ?? 0}`}
                        unit={dead ? '' : 'mmHg'}
                        status={data.bpStatus}
                    />
                    <VitalCell
                        label="SpO₂"
                        value={dead ? '—' : data.spo2 ?? 0}
                        unit={dead ? '' : '%'}
                        status={data.spo2Status}
                    />
                    <VitalCell
                        label="RR"
                        value={dead ? 0 : data.rr ?? 0}
                        unit="/min"
                        status={data.rrStatus}
                    />
                    <VitalCell
                        label="TEMP"
                        value={(Number(data.temp) || 0).toFixed(1)}
                        unit="°C"
                    />
                </div>

                <div className="vm-row">
                    <div className="vm-blood">
                        <div className="vm-cell-label">Blood volume</div>
                        <div className="vm-bar">
                            <div
                                className={`vm-bar-fill ${tone(data.bloodStatus)}`}
                                style={{ width: `${Math.max(0, Math.min(100, Number(data.blood) || 0))}%` }}
                            />
                        </div>
                        <div className="vm-blood-val">
                            {data.blood ?? 0}% <span>{data.bloodStatus || ''}</span>
                        </div>
                    </div>
                    <div className={`vm-bleed ${Number(data.bleedLevel) > 0 ? 'bad' : 'ok'}`}>
                        <div className="vm-cell-label">Bleeding</div>
                        <div className="vm-bleed-val">{data.bleeding || 'None'}</div>
                    </div>
                </div>

                <div className="vm-injuries">
                    <div className="vm-cell-label">Injured areas</div>
                    {injuries.length < 1 ? (
                        <div className="vm-chip ok">{data.area && data.area !== 'NONE' ? data.area : 'No traumatic injury'}</div>
                    ) : (
                        <div className="vm-chips">
                            {injuries.map((inj) => (
                                <div key={`${inj.label}-${inj.severity}`} className={`vm-chip ${inj.severity >= 3 ? 'bad' : 'warn'}`}>
                                    {inj.label}
                                    <em>{inj.wound}</em>
                                </div>
                            ))}
                        </div>
                    )}
                </div>

                <footer className="vm-footer">
                    <span>Rhythm {data.rhythm || 'NSR'}</span>
                    <span>Health {data.health ?? 0}%</span>
                    <span>Armor {data.armor ?? 0}</span>
                </footer>
            </motion.div>
        </div>
    );
}

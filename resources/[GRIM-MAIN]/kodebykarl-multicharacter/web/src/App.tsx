import React, { useState, useEffect } from 'react';
import Multicharacter, { Character } from './modules/kodebykarl-multicharacter/Multicharacter';
import Multivip, { MultivipData } from './modules/kodebykarl-multicharacter/Multivip';

function resourceName() {
  return (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : 'kodebykarl-multicharacter';
}

const App: React.FC = () => {
  const [multicharVisible, setMulticharVisible] = useState<boolean>(false);
  const [characters, setCharacters] = useState<Character[]>([]);
  const [maxSlots, setMaxSlots] = useState<number>(1);
  const [multivipVisible, setMultivipVisible] = useState<boolean>(false);
  const [multivipData, setMultivipData] = useState<MultivipData | null>(null);

  useEffect(() => {
    fetch(`https://${resourceName()}/nuiReady`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({}),
    }).catch(() => {});

    const handleNuiMessage = (event: MessageEvent) => {
      const data = event.data;
      if (!data || typeof data !== 'object') return;

      if (data.action === 'openMulticharacter') {
        setCharacters(data.characters || []);
        setMaxSlots(data.maxSlots || 1);
        setMulticharVisible(true);
      } else if (data.action === 'closeMulticharacter') {
        setMulticharVisible(false);
      } else if (data.action === 'openMultivip') {
        setMultivipData(data.data || { players: [] });
        setMultivipVisible(true);
      } else if (data.action === 'closeMultivip') {
        setMultivipVisible(false);
      }
    };

    window.addEventListener('message', handleNuiMessage);
    return () => window.removeEventListener('message', handleNuiMessage);
  }, []);

  const closeMultivip = () => {
    setMultivipVisible(false);
    fetch(`https://${resourceName()}/closeMultivip`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({}),
    }).catch(() => {});
  };

  return (
    <div className="ui-container">
      {multicharVisible && (
        <Multicharacter
          characters={characters}
          maxSlots={maxSlots}
          onClose={() => setMulticharVisible(false)}
        />
      )}
      {multivipVisible && (
        <Multivip data={multivipData} onClose={closeMultivip} />
      )}
    </div>
  );
};

export default App;

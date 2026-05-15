import { useState, useCallback, useEffect } from 'react';
import { isDebug, useNuiEvent, fetchNui } from './hooks/useNui';
import RentalMenu, { Vehicle } from './components/RentalMenu';

const mockVehicles: Vehicle[] = [
  { id: 'faggio', name: 'Pegassi Faggio Classic', description: 'Small Scooter - $50 with a $50 Deposit.' },
  { id: 'tulip', name: 'Declasse Tulip Beater', description: 'Rust Bucket - $100 with a $100 Deposit.' },
  { id: 'asbo', name: 'Maxwell Asbo', description: 'Small British Hatchback - $125 with a $125 Deposit.' },
  { id: 'dilettante', name: 'Karin Dilettante', description: 'Small Hybrid Hatchback - $150 with a $150 Deposit.' },
  { id: 'asterope', name: 'Karin Asterope', description: 'Mid-Size Sedan - $175 with a $175 Deposit.' },
];

export default function App() {
  const [visible, setVisible] = useState(isDebug);
  const [vehicles, setVehicles] = useState<Vehicle[]>(mockVehicles);

  useNuiEvent('open', (data: { vehicles?: Vehicle[] }) => {
    if (data.vehicles) setVehicles(data.vehicles);
    setVisible(true);
  });
  useNuiEvent('close', () => setVisible(false));

  const handleClose = useCallback(() => {
    setVisible(false);
    fetchNui('close', {}, { success: true });
  }, []);

  const handleSelect = useCallback((vehicle: Vehicle) => {
    fetchNui('selectVehicle', { vehicleId: vehicle.id }, { success: true });
    handleClose();
  }, [handleClose]);

  useEffect(() => {
    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') handleClose();
    };
    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [handleClose]);

  if (!visible) return null;

  return (
    <RentalMenu
      title="CHEAP-O RENT-A-CAR"
      vehicles={vehicles}
      onSelect={handleSelect}
      onClose={handleClose}
    />
  );
}

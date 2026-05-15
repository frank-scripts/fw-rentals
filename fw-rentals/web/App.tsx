import { useState, useCallback, useEffect } from 'react';
import { isDebug, useNuiEvent, fetchNui } from './hooks/useNui';
import Menu, { MenuItem } from './components/Menu';
import RentalMenu, { Vehicle } from './components/RentalMenu';

const mockVehicles: Vehicle[] = [
  { id: 'faggio', make: 'Pegassi', name: 'Faggio', description: 'A small, zippy scooter perfect for city commuting.', deposit: 50, payment: 50 },
  { id: 'tulip2', make: 'Declasse', name: 'Tulip Beater', description: 'A rusted but reliable beater with character.', deposit: 100, payment: 100 },
  { id: 'asbo', make: 'Maxwell', name: 'Asbo', description: 'A compact British hatchback with personality.', deposit: 125, payment: 125 },
  { id: 'dilettante', make: 'Karin', name: 'Dilettante', description: 'An affordable hybrid hatchback for the eco-conscious.', deposit: 150, payment: 150 },
  { id: 'asterope', make: 'Karin', name: 'Asterope', description: 'A reliable mid-size sedan for everyday driving.', deposit: 200, payment: 200 },
];

const mockMenuItems: MenuItem[] = [
  { id: 'option1', label: 'Check Balance', description: 'View your current bank balance' },
  { id: 'option2', label: 'Transfer Money', description: 'Send money to another player' },
  { id: 'option3', label: 'Deposit Cash', description: 'Deposit cash into your bank account' },
];

type MenuMode = 'none' | 'generic' | 'rental';

interface MenuData {
  menuId: string;
  title: string;
  items: MenuItem[];
  position?: 'left' | 'right';
}

interface RentalData {
  vehicles: Vehicle[];
}

export default function App() {
  const [mode, setMode] = useState<MenuMode>(isDebug ? 'generic' : 'none');
  const [menuData, setMenuData] = useState<MenuData>({
    menuId: 'debug',
    title: 'BANK MENU',
    items: mockMenuItems,
    position: 'right',
  });
  const [vehicles, setVehicles] = useState<Vehicle[]>(mockVehicles);

  // Generic menu events
  useNuiEvent('open', (data: MenuData & RentalData) => {
    if (data.menuId && data.items) {
      // Generic menu mode
      setMenuData({
        menuId: data.menuId,
        title: data.title,
        items: data.items,
        position: data.position || 'right',
      });
      setMode('generic');
    } else if (data.vehicles) {
      // Rental menu mode (backward compatible)
      setVehicles(data.vehicles);
      setMode('rental');
    }
  });

  useNuiEvent('close', () => setMode('none'));
  
  useNuiEvent('updateItems', (data: { items: MenuItem[] }) => {
    setMenuData(prev => ({ ...prev, items: data.items }));
  });

  const handleClose = useCallback(() => {
    setMode('none');
    fetchNui('close', {}, { success: true });
  }, []);

  const handleMenuSelect = useCallback((item: MenuItem) => {
    fetchNui('menuSelect', { item }, { success: true });
  }, []);

  const handleRentalSelect = useCallback((vehicle: Vehicle) => {
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

  if (mode === 'none') return null;

  if (mode === 'rental') {
    return (
      <RentalMenu
        title="CHEAP-O RENT-A-CAR"
        vehicles={vehicles}
        onSelect={handleRentalSelect}
        onClose={handleClose}
      />
    );
  }

  return (
    <Menu
      id={menuData.menuId}
      title={menuData.title}
      items={menuData.items}
      position={menuData.position}
      onSelect={handleMenuSelect}
      onClose={handleClose}
    />
  );
}

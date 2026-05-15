import { useState, useRef, useEffect } from 'react';

export interface Vehicle {
  id: string;
  name: string;
  description: string;
}

interface RentalMenuProps {
  title: string;
  vehicles: Vehicle[];
  onSelect: (vehicle: Vehicle) => void;
  onClose: () => void;
}

export default function RentalMenu({ title, vehicles, onSelect, onClose }: RentalMenuProps) {
  const [hoveredId, setHoveredId] = useState<string | null>(null);
  const [isAtBottom, setIsAtBottom] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  const handleScroll = () => {
    const el = scrollRef.current;
    if (!el) return;
    
    const isBottom = el.scrollHeight - el.scrollTop <= el.clientHeight + 10;
    setIsAtBottom(isBottom);
  };

  useEffect(() => {
    const el = scrollRef.current;
    if (el) {
      el.addEventListener('scroll', handleScroll);
      handleScroll(); // Check initial state
      return () => el.removeEventListener('scroll', handleScroll);
    }
  }, []);

  return (
    <div className="fixed right-0 top-0 h-full flex items-center pr-6 pointer-events-none"
         style={{ perspective: '1200px' }}>
      <div 
        className="pointer-events-auto flex flex-col gap-2"
        style={{
          width: '420px',
          transform: 'rotateY(-8deg) rotateX(2deg)',
          transformStyle: 'preserve-3d',
        }}
      >
        {/* Header Row */}
        <div className="flex gap-2">
          <header 
            className="flex-1 px-5 py-3 flex items-center rounded-xl"
            style={{
              background: 'rgba(30, 30, 47, 0.9)',
              boxShadow: '0 4px 20px rgba(0, 0, 0, 0.4), 0 0 30px rgba(139, 92, 246, 0.15)',
              border: '1px solid rgba(139, 92, 246, 0.3)',
            }}
          >
            <h1 
              className="font-bold tracking-wide"
              style={{ 
                color: '#fff',
                fontSize: '15px',
              }}
            >
              {title}
            </h1>
          </header>
          <button
            onClick={onClose}
            className="w-11 h-11 flex items-center justify-center rounded-xl transition-all duration-200 hover:bg-purple-500/20"
            style={{
              background: 'rgba(30, 30, 47, 0.9)',
              boxShadow: '0 4px 20px rgba(0, 0, 0, 0.4)',
              border: '1px solid rgba(139, 92, 246, 0.3)',
              color: 'rgba(255, 255, 255, 0.8)',
            }}
          >
            <span className="text-xl leading-none">×</span>
          </button>
        </div>

        {/* Menu Items */}
        <div className="relative">
          <div 
            ref={scrollRef}
            className="flex flex-col gap-2 overflow-y-auto pr-1"
            style={{
              maxHeight: '60vh',
              maskImage: isAtBottom ? 'none' : 'linear-gradient(to bottom, black 80%, transparent 100%)',
              WebkitMaskImage: isAtBottom ? 'none' : 'linear-gradient(to bottom, black 80%, transparent 100%)',
            }}
          >
          {vehicles.map((vehicle) => {
            const isHovered = hoveredId === vehicle.id;
            return (
              <button
                key={vehicle.id}
                onClick={() => onSelect(vehicle)}
                onMouseEnter={() => setHoveredId(vehicle.id)}
                onMouseLeave={() => setHoveredId(null)}
                className="flex items-center justify-between text-left transition-all duration-200 rounded-xl"
                style={{
                  padding: '16px 20px',
                  background: isHovered 
                    ? 'rgba(139, 92, 246, 0.25)'
                    : 'rgba(18, 18, 28, 0.85)',
                  boxShadow: isHovered 
                    ? '0 4px 20px rgba(139, 92, 246, 0.3), inset 0 0 0 1px rgba(168, 85, 247, 0.5)'
                    : '0 4px 15px rgba(0, 0, 0, 0.3)',
                  border: isHovered 
                    ? '1px solid rgba(168, 85, 247, 0.6)' 
                    : '1px solid rgba(255, 255, 255, 0.08)',
                }}
              >
                <div className="flex-1 min-w-0">
                  <h2 
                    className="font-semibold"
                    style={{ 
                      color: '#fff',
                      fontSize: '15px',
                      marginBottom: '4px',
                    }}
                  >
                    {vehicle.name}
                  </h2>
                  <p 
                    className="truncate"
                    style={{ 
                      color: 'rgba(255, 255, 255, 0.55)',
                      fontSize: '13px',
                    }}
                  >
                    {vehicle.description}
                  </p>
                </div>
                <svg
                  className="flex-shrink-0 transition-all duration-200"
                  style={{
                    width: '16px',
                    height: '16px',
                    marginLeft: '18px',
                    color: isHovered ? '#c084fc' : 'rgba(255, 255, 255, 0.4)',
                    transform: isHovered ? 'translateX(3px)' : 'translateX(0)',
                  }}
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2.5"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <polyline points="9 18 15 12 9 6"></polyline>
                </svg>
              </button>
            );
          })}
          </div>
        </div>
      </div>
    </div>
  );
}

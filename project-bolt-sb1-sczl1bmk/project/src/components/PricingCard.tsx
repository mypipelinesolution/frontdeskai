import { Check } from 'lucide-react';

interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  priceId: string;
  features?: string[];
}

interface PricingCardProps {
  product: Product;
  featured?: boolean;
  onSelect: (priceId: string) => void;
}

export function PricingCard({ product, featured = false, onSelect }: PricingCardProps) {
  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(price / 100);
  };

  return (
    <div
      className={`relative bg-white rounded-xl shadow-lg border-2 transition-all duration-300 hover:shadow-xl ${
        featured
          ? 'border-blue-500 ring-2 ring-blue-200'
          : 'border-gray-200 hover:border-blue-300'
      }`}
    >
      {featured && (
        <div className="absolute -top-4 left-1/2 transform -translate-x-1/2">
          <span className="bg-gradient-to-r from-blue-500 to-blue-600 text-white px-4 py-1 rounded-full text-xs font-bold uppercase shadow-lg">
            Most Popular
          </span>
        </div>
      )}

      <div className="p-6">
        <h3 className="text-xl font-bold text-gray-900 mb-2">
          {product.name.replace('FrontDesk AI Pro — ', '')}
        </h3>

        <div className="mb-4">
          <span className="text-4xl font-bold text-gray-900">
            {formatPrice(product.price)}
          </span>
          <span className="text-gray-600 text-sm">/month</span>
        </div>

        <p className="text-gray-600 text-sm mb-6 min-h-[3rem]">
          {product.description}
        </p>

        {product.features && product.features.length > 0 && (
          <ul className="space-y-3 mb-6">
            {product.features.map((feature, index) => (
              <li key={index} className="flex items-start">
                <Check className="w-5 h-5 text-green-500 mr-2 mt-0.5 flex-shrink-0" />
                <span className="text-gray-700 text-sm">{feature}</span>
              </li>
            ))}
          </ul>
        )}

        <button
          onClick={() => onSelect(product.priceId)}
          className={`w-full py-3 px-6 rounded-lg font-semibold transition-all duration-200 ${
            featured
              ? 'bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white shadow-lg shadow-blue-500/30'
              : 'bg-gray-900 hover:bg-gray-800 text-white'
          }`}
        >
          Get Started
        </button>
      </div>
    </div>
  );
}

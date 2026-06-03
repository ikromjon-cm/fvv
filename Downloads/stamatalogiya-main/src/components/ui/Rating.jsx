import AppIcon from './AppIcon';

export default function Rating({ value, className = '' }) {
  return (
    <span className={`rating${className ? ` ${className}` : ''}`}>
      <AppIcon name="star" size={14} className="rating-star" />
      {value}
    </span>
  );
}

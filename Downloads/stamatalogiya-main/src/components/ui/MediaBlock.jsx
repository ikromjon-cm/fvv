import { useState } from 'react';
import AppIcon from './AppIcon';

export default function MediaBlock({
  type = 'default',
  variant = 'card',
  label,
  src,
  alt,
  fit = 'cover',
  children,
}) {
  const [imgError, setImgError] = useState(false);
  const fitClass = fit === 'contain' ? ' media-contained' : '';
  const showImg = src && !imgError;
  const ariaLabel = label || type;

  return (
    <div
      className={`media media-${variant}${fitClass}${imgError ? ' is-error' : ''}`}
      role={showImg ? undefined : 'img'}
      aria-label={!showImg ? ariaLabel : undefined}
    >
      <div className="media-bg" aria-hidden="true" />
      {showImg && (
        <img
          className="media-img"
          src={src}
          alt={alt || ariaLabel}
          loading="lazy"
          decoding="async"
          draggable={false}
          sizes="(max-width: 479px) 100vw, (max-width: 767px) 50vw, 33vw"
          onError={() => setImgError(true)}
        />
      )}
      <div className="media-fallback" aria-hidden="true">
        {!showImg && <AppIcon name={type} size={variant === 'course' ? 40 : 32} className="media-icon-svg" />}
      </div>
      {children}
    </div>
  );
}

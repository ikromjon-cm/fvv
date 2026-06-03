import { useDispatch } from 'react-redux';
import { addToCart } from '../../store/slices/marketplaceSlice';
import { useTranslation } from '../../hooks/useTranslation';
import MediaBlock from './MediaBlock';
import Rating from './Rating';

export default function ProductCard({ product }) {
  const dispatch = useDispatch();
  const { t } = useTranslation();

  return (
    <article className="card">
      <MediaBlock
        type={product.image}
        variant="card"
        label={product.title}
        src={product.imageUrl}
      >
        {product.featured && (
          <span className="media-badge badge badge-gold">{t('common.featured')}</span>
        )}
      </MediaBlock>
      <div className="card-body">
        <span className="badge badge-teal">{t(`categories.${product.category}`)}</span>
        <h3 className="card-title">{product.title}</h3>
        <p className="card-meta">{product.seller}</p>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '0.75rem' }}>
          <span className="price">${product.price.toLocaleString()}</span>
          <Rating value={product.rating} />
        </div>
        <button
          type="button"
          className="btn btn-primary"
          style={{ width: '100%', marginTop: '1rem' }}
          onClick={() => dispatch(addToCart(product))}
        >
          {t('common.addToCart')}
        </button>
      </div>
    </article>
  );
}

import { useDispatch, useSelector } from 'react-redux';
import { Link, useParams } from 'react-router-dom';
import { enrollCourse } from '../store/slices/coursesSlice';
import PremiumGate from '../components/layout/PremiumGate';
import Rating from '../components/ui/Rating';
import AppIcon from '../components/ui/AppIcon';
import { useTranslation } from '../hooks/useTranslation';

export default function CourseDetail() {
  const { id } = useParams();
  const dispatch = useDispatch();
  const { t } = useTranslation();
  const { courses, enrolled } = useSelector((state) => state.courses);
  const course = courses.find((c) => String(c.id) === String(id));

  if (!course) {
    return (
      <div className="page">
        <div className="empty">{t('common.noResults')}</div>
        <Link to="/academy" className="btn btn-primary">{t('nav.academy')}</Link>
      </div>
    );
  }

  const embedUrl = `https://www.youtube.com/embed/${course.youtubeId}?rel=0&modestbranding=1`;

  return (
    <div className="page">
      <Link to="/academy" className="back-link">
        &larr; {t('nav.academy')}
      </Link>

      <div className="course-detail">
        <div className="video-player-wrap">
          <iframe
            title={course.title}
            src={embedUrl}
            className="video-player"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        </div>

        <div className="course-detail-body">
          <span className="badge badge-teal">{course.level}</span>
          <h1 className="title">{course.title}</h1>
          <p className="subtitle">{course.instructor}</p>
          <div className="tech-meta">
            <Rating value={course.rating} />
            <span className="card-meta">
              <AppIcon name="video" size={14} />
              {course.lessons} {t('common.lessons')} &middot; {course.duration}
            </span>
          </div>

          <PremiumGate message={t('academy.registerEnroll')}>
            <button
              type="button"
              className="btn btn-gold"
              onClick={() => dispatch(enrollCourse(course.id))}
              disabled={enrolled.includes(course.id)}
            >
              {enrolled.includes(course.id) ? t('common.enrolled') : t('common.enroll')}
            </button>
          </PremiumGate>

          <a
            href={`https://www.youtube.com/watch?v=${course.youtubeId}`}
            target="_blank"
            rel="noopener noreferrer"
            className="btn btn-outline"
            style={{ marginLeft: '0.75rem' }}
          >
            <AppIcon name="external" size={16} />
            YouTube
          </a>
        </div>
      </div>
    </div>
  );
}

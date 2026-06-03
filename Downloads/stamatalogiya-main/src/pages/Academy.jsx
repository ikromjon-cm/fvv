import { useDispatch, useSelector } from 'react-redux';
import { Link } from 'react-router-dom';
import { courseCategories } from '../data/mockData';
import { setCourseCategory, enrollCourse } from '../store/slices/coursesSlice';
import PremiumGate from '../components/layout/PremiumGate';
import MediaBlock from '../components/ui/MediaBlock';
import Rating from '../components/ui/Rating';
import AppIcon from '../components/ui/AppIcon';
import { useTranslation } from '../hooks/useTranslation';

const levelKeys = {
  Advanced: 'advanced',
  Intermediate: 'intermediate',
  Expert: 'expert',
  Beginner: 'beginner',
};

export default function Academy() {
  const dispatch = useDispatch();
  const { t } = useTranslation();
  const { courses, activeCategory, enrolled } = useSelector((state) => state.courses);

  const filtered = activeCategory === 'all'
    ? courses
    : courses.filter((c) => c.category === activeCategory);

  return (
    <div className="page">
      <div className="section-header">
        <div>
          <span className="label">{t('academy.label')}</span>
          <h1 className="title">{t('academy.title')}</h1>
          <p className="subtitle">{t('academy.subtitle')}</p>
        </div>
      </div>

      <div className="filter" style={{ marginBottom: '1.5rem' }}>
        <button
          type="button"
          className={`chip${activeCategory === 'all' ? ' active' : ''}`}
          onClick={() => dispatch(setCourseCategory('all'))}
        >
          {t('common.allCourses')}
        </button>
        {courseCategories.map((cat) => (
          <button
            key={cat.id}
            type="button"
            className={`chip${activeCategory === cat.id ? ' active' : ''}`}
            onClick={() => dispatch(setCourseCategory(cat.id))}
          >
            {t(`courseCategories.${cat.id}`)}
          </button>
        ))}
      </div>

      <div className="grid grid-3 grid-products">
        {filtered.map((course) => (
          <article key={course.id} className="card">
            <Link to={`/academy/${course.id}`} className="course-thumb-link">
              <div className="course-thumb-wrap">
                <MediaBlock
                  type="course"
                  variant="course"
                  label={course.title}
                  src={course.imageUrl || `https://img.youtube.com/vi/${course.youtubeId}/hqdefault.jpg`}
                />
                <div className="course-play">
                  <span className="play-btn" aria-hidden="true">
                    <AppIcon name="play" size={20} />
                  </span>
                </div>
                {course.progress > 0 && (
                  <span className="course-progress-badge badge badge-teal">
                    {course.progress}% {t('common.complete')}
                  </span>
                )}
              </div>
            </Link>
            <div className="card-body">
              <span className="badge badge-teal">{t(`levels.${levelKeys[course.level] || 'intermediate'}`)}</span>
              <h3 className="card-title">
                <Link to={`/academy/${course.id}`}>{course.title}</Link>
              </h3>
              <div className="instructor">
                <div className="instructor-avatar">
                  {course.instructor.split(' ').map((n) => n[0]).slice(0, 2).join('')}
                </div>
                <span className="card-meta">{course.instructor}</span>
              </div>
              <p className="card-meta course-meta-row">
                <AppIcon name="video" size={14} />
                {course.lessons} {t('common.lessons')} &middot; {course.duration} &middot; {course.students} {t('common.students')}
              </p>
              {course.progress > 0 && (
                <div className="progress">
                  <div className="progress-bar" style={{ width: `${course.progress}%` }} />
                </div>
              )}
              <div className="card-row">
                <span className="price">${course.price}</span>
                <Rating value={course.rating} />
              </div>
              <PremiumGate message={t('academy.registerEnroll')}>
                <div className="course-actions">
                  <Link to={`/academy/${course.id}`} className="btn btn-outline" style={{ flex: 1 }}>
                    {t('academy.watchLesson')}
                  </Link>
                  <button
                    type="button"
                    className="btn btn-primary"
                    style={{ flex: 1 }}
                    onClick={() => dispatch(enrollCourse(course.id))}
                    disabled={enrolled.includes(course.id)}
                  >
                    {enrolled.includes(course.id) ? t('common.enrolled') : t('common.enroll')}
                  </button>
                </div>
              </PremiumGate>
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

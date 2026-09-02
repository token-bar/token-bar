import { useTranslation } from 'react-i18next';

const SCREENSHOTS = [
  '/tokenbar1.png',
  '/tokenbar2.png',
  '/tokenbar3.png',
  '/tokenbar4.png',
  '/tokenbar5.png',
] as const;

export function ScreenshotCarousel() {
  const { t } = useTranslation();
  const slides = [...SCREENSHOTS, ...SCREENSHOTS];

  return (
    <div
      className="screenshot-carousel screenshot-carousel--mac"
      aria-label={t('home.heroAlt')}
    >
      <div className="screenshot-carousel__viewport">
        <div className="screenshot-carousel__track">
          {slides.map((src, index) => (
            <img
              key={`${src}-${index}`}
              src={src}
              alt={t('home.heroAlt')}
              className="screenshot-carousel__slide"
              loading={index < 2 ? 'eager' : 'lazy'}
              decoding="async"
              draggable={false}
            />
          ))}
        </div>
      </div>
      <div className="screenshot-carousel__edge screenshot-carousel__edge--left" aria-hidden />
      <div className="screenshot-carousel__edge screenshot-carousel__edge--right" aria-hidden />
    </div>
  );
}

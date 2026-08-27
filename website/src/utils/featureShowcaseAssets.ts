/**
 * Feature showcase screenshots live in `website/public/`.
 *
 * Naming (one pair per feature key):
 *   feature-{key}-light.png
 *   feature-{key}-dark.png
 *
 * Keys: menuBar | providers | forecast | alerts | widget | privacy
 */
export const FEATURE_SHOWCASE_KEYS = [
  'menuBar',
  'providers',
  'forecast',
  'alerts',
  'widget',
  'privacy',
] as const;

export type FeatureShowcaseKey = (typeof FEATURE_SHOWCASE_KEYS)[number];

export function featureShowcaseImageSrc(key: FeatureShowcaseKey, theme: 'light' | 'dark') {
  return `/feature-${key}-${theme}.png`;
}

function probeImage(src: string): Promise<boolean> {
  return new Promise((resolve) => {
    const image = new Image();
    image.onload = () => resolve(true);
    image.onerror = () => resolve(false);
    image.src = src;
  });
}

export async function probeFeatureShowcaseImages(key: FeatureShowcaseKey) {
  const lightSrc = featureShowcaseImageSrc(key, 'light');
  const darkSrc = featureShowcaseImageSrc(key, 'dark');
  const [hasLight, hasDark] = await Promise.all([probeImage(lightSrc), probeImage(darkSrc)]);

  return { hasLight, hasDark, lightSrc, darkSrc };
}

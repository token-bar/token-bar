export const GITHUB_ORG = 'token-bar';

export const GITHUB_REPO = 'token-bar/token-bar';

export const GITHUB_OWNER = 'xarlizard';

export const GITHUB_ORG_URL = `https://github.com/${GITHUB_ORG}`;

export const REPO_URL = `https://github.com/${GITHUB_REPO}`;

export const GITHUB_PROFILE_URL = `https://github.com/${GITHUB_OWNER}`;

export const APP_NAME = 'TokenBar';

export const APP_NAME_SHORT = 'TokenBar';

export const SITE_URL = 'https://token-bar.pages.dev';

export const GITHUB_RELEASES_API = `https://api.github.com/repos/${GITHUB_REPO}/releases/latest`;

export const RELEASES_PAGE_URL = `https://github.com/${GITHUB_REPO}/releases/latest`;

interface GitHubReleaseAsset {
  name: string;
  browser_download_url: string;
}

interface GitHubLatestRelease {
  assets?: GitHubReleaseAsset[];
}

/** Resolves the newest release `.dmg` asset (e.g. TokenBar-0.1.0.dmg). */
export async function fetchLatestDmgDownloadUrl(): Promise<string | null> {
  const response = await fetch(GITHUB_RELEASES_API);
  if (!response.ok) {
    return null;
  }

  const release = (await response.json()) as GitHubLatestRelease;
  const dmg = release.assets?.find((asset) => asset.name.toLowerCase().endsWith('.dmg'));
  return dmg?.browser_download_url ?? null;
}

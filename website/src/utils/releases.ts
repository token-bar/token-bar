export const GITHUB_REPO = 'token-bar/token-bar';

export const GITHUB_RELEASES_API = `https://api.github.com/repos/${GITHUB_REPO}/releases/latest`;

export const RELEASES_PAGE_URL = `https://github.com/${GITHUB_REPO}/releases/latest`;

export const REPO_URL = `https://github.com/${GITHUB_REPO}`;

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

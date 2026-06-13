import { useEffect, useState } from 'react';
import { fetchLatestDmgDownloadUrl, RELEASES_PAGE_URL } from '@/utils/releases';

export function useLatestDmgUrl() {
  const [url, setUrl] = useState(RELEASES_PAGE_URL);

  useEffect(() => {
    let cancelled = false;

    fetchLatestDmgDownloadUrl()
      .then((downloadUrl) => {
        if (!cancelled && downloadUrl) {
          setUrl(downloadUrl);
        }
      })
      .catch(() => {
        /* keep releases page fallback */
      });

    return () => {
      cancelled = true;
    };
  }, []);

  const isDirectDownload = url !== RELEASES_PAGE_URL;

  return { url, isDirectDownload };
}

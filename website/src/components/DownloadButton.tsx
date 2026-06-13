import { Download } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { Button } from '@/components/ui/button';
import { useLatestDmgUrl } from '@/hooks/useLatestDmgUrl';

interface DownloadButtonProps {
  size?: 'default' | 'sm' | 'lg';
  className?: string;
}

export function DownloadButton({ size = 'default', className }: DownloadButtonProps) {
  const { t } = useTranslation();
  const { url, isDirectDownload } = useLatestDmgUrl();

  return (
    <Button asChild size={size} className={className}>
      <a href={url} {...(isDirectDownload ? { download: true } : {})}>
        <Download className="size-4" />
        {t('download.label')}
      </a>
    </Button>
  );
}

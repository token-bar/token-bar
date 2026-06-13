import { useTranslation } from 'react-i18next';
import { ExternalLink } from 'lucide-react';
import { DownloadButton } from '@/components/DownloadButton';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

const repoDocLinks = [
  { key: 'development', href: 'https://github.com/token-bar/token-bar/blob/main/docs/development.md' },
  { key: 'architecture', href: 'https://github.com/token-bar/token-bar/blob/main/docs/architecture.md' },
  { key: 'contributing', href: 'https://github.com/token-bar/token-bar/blob/main/CONTRIBUTING.md' },
  { key: 'changelog', href: 'https://github.com/token-bar/token-bar/blob/main/CHANGELOG.md' },
  { key: 'security', href: 'https://github.com/token-bar/token-bar/blob/main/SECURITY.md' },
] as const;

const providerKeys = [
  'cursorPersonal',
  'cursorTeam',
  'openai',
  'anthropic',
  'proxy',
  'demo',
] as const;

function StepList({ steps }: { steps: string[] }) {
  return (
    <ol className="list-decimal space-y-2 pl-5 text-sm text-muted-foreground">
      {steps.map((step) => (
        <li key={step}>{step}</li>
      ))}
    </ol>
  );
}

export default function DocsPage() {
  const { t } = useTranslation();

  const installSteps = t('docs.installSteps', { returnObjects: true }) as string[];
  const quickStartSteps = t('docs.quickStartSteps', { returnObjects: true }) as string[];

  return (
    <main className="mx-auto flex w-full max-w-3xl flex-col gap-8 pb-8">
      <header className="space-y-3 text-center sm:text-left">
        <h1 className="text-3xl font-semibold tracking-tight">{t('docs.title')}</h1>
        <p className="text-muted-foreground text-pretty">{t('docs.subtitle')}</p>
        <div className="flex flex-wrap items-center justify-center gap-3 sm:justify-start">
          <DownloadButton />
          <p className="text-xs text-muted-foreground">{t('download.hint')}</p>
        </div>
      </header>

      <Card>
        <CardHeader>
          <CardTitle className="text-lg">{t('docs.installTitle')}</CardTitle>
        </CardHeader>
        <CardContent>
          <StepList steps={installSteps} />
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-lg">{t('docs.quickStartTitle')}</CardTitle>
        </CardHeader>
        <CardContent>
          <StepList steps={quickStartSteps} />
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-lg">{t('docs.providersTitle')}</CardTitle>
        </CardHeader>
        <CardContent>
          <ul className="space-y-2 text-sm text-muted-foreground">
            {providerKeys.map((key) => (
              <li key={key}>{t(`docs.providers.${key}`)}</li>
            ))}
          </ul>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-lg">{t('docs.repoDocsTitle')}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <p className="text-sm text-muted-foreground">{t('docs.repoDocsDescription')}</p>
          <ul className="space-y-2">
            {repoDocLinks.map(({ key, href }) => (
              <li key={key}>
                <a
                  href={href}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-1.5 text-sm font-medium text-primary underline-offset-4 hover:underline"
                >
                  {t(`docs.links.${key}`)}
                  <ExternalLink className="size-3.5" aria-hidden />
                </a>
              </li>
            ))}
          </ul>
        </CardContent>
      </Card>
    </main>
  );
}

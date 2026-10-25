export const metadata = {
  title: 'LIGA SKALAMA — Dia de Fut',
  description: 'Organização da Liga Skalama: sorteio, partidas, placares e estatísticas.',
  icons: { icon: '/liga-skalama/assets/escudo-skalama-oficial.png' },
};

export const viewport = {
  width: 'device-width',
  initialScale: 1,
  themeColor: '#f4f4f1',
};

export default function RootLayout({ children }) {
  return (
    <html lang="pt-BR">
      <head>
        <link rel="stylesheet" href="/liga-skalama/styles.css" />
      </head>
      <body className="light-theme">{children}</body>
    </html>
  );
}


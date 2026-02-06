import Link from "next/link";

export default function Home() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[calc(100vh-140px)] px-4 text-center">
      <div className="max-w-3xl space-y-8">
        <div className="space-y-4">
          <h1 className="text-5xl md:text-7xl font-bold tracking-tighter text-transparent bg-clip-text bg-gradient-to-br from-white to-gray-400 pb-2">
            Klypt
          </h1>
          <p className="text-xl md:text-2xl text-gray-400 font-light max-w-2xl mx-auto">
            Offline, zero-knowledge password manager — built as a micro project.
          </p>
        </div>

        <p className="text-gray-500 max-w-xl mx-auto text-lg leading-relaxed">
          Take full control of your digital security with an open-source, offline-first password manager that never sends your data to the cloud.
        </p>

        <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-4">
          <Link
            href="/download"
            className="w-full sm:w-auto px-8 py-4 bg-white text-black hover:bg-gray-200 rounded-lg text-lg font-semibold transition-all shadow-lg shadow-white/5 active:scale-95"
          >
            Download Android App
          </Link>
          <Link
            href="/how-it-works"
            className="w-full sm:w-auto px-8 py-4 border border-white/20 hover:border-white/40 hover:bg-white/5 rounded-lg text-lg font-medium transition-all active:scale-95"
          >
            Read Documentation
          </Link>
        </div>
      </div>
    </div>
  );
}

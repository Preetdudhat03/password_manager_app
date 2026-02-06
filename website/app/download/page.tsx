import Link from 'next/link';

export const metadata = {
    title: "Download | Klypt",
    description: "Download the latest version of Klypt for Android.",
};

export default function DownloadPage() {
    return (
        <div className="flex flex-col items-center justify-center min-h-[60vh] px-4 text-center">
            <div className="max-w-2xl w-full space-y-12">
                <h1 className="text-4xl font-bold tracking-tight text-white">Download Klypt</h1>

                <div className="bg-white/5 rounded-2xl p-8 border border-white/10 shadow-2xl">
                    <Link
                        href="/securevault.apk"
                        className="block w-full py-5 bg-white text-black hover:bg-gray-200 rounded-xl text-xl font-bold transition-all shadow-lg active:scale-95 mb-6"
                        download
                    >
                        Download APK (Android)
                    </Link>

                    <div className="grid grid-cols-3 gap-4 text-sm text-gray-400 border-t border-white/10 pt-6">
                        <div className="text-center">
                            <span className="block text-gray-500 text-xs uppercase tracking-wider mb-1">Version</span>
                            <span className="font-mono text-white">v1.0.0</span>
                        </div>
                        <div className="text-center border-l border-white/10">
                            <span className="block text-gray-500 text-xs uppercase tracking-wider mb-1">Size</span>
                            <span className="font-mono text-white">~15 MB</span>
                        </div>
                        <div className="text-center border-l border-white/10">
                            <span className="block text-gray-500 text-xs uppercase tracking-wider mb-1">Min Android</span>
                            <span className="font-mono text-white">8.0+</span>
                        </div>
                    </div>
                </div>

                <div className="space-y-4 max-w-lg mx-auto">
                    <p className="text-yellow-500/80 text-sm">
                        ⚠️ <strong>Note:</strong> You may need to "Allow installation from unknown sources" in your settings since this is a micro-project and not on the Play Store.
                    </p>

                    <div className="text-gray-500 text-xs">
                        <p>Hash (SHA-256): <span className="font-mono bg-white/5 px-2 py-1 rounded">Pending Build</span></p>
                    </div>
                </div>

                <div className="pt-8">
                    <Link href="https://github.com/Preetdudhat03/password_manager_app/releases" className="text-blue-400 hover:text-blue-300 underline underline-offset-4" target="_blank">
                        View Source Code & Releases on GitHub
                    </Link>
                </div>
            </div>
        </div>
    );
}

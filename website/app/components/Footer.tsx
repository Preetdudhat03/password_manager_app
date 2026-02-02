import Link from 'next/link';

export default function Footer() {
    return (
        <footer className="border-t border-white/10 bg-black py-12 mt-auto">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-center">

                    <div className="text-center md:text-left">
                        <p className="text-base text-gray-400">
                            Built as a learning-focused micro project by <span className="text-white">Preet Dudhat</span>.
                        </p>
                        <p className="text-sm text-gray-500 mt-2">
                            Not intended for production use.
                        </p>
                    </div>

                    <div className="flex justify-center md:justify-end space-x-6">
                        <Link href="https://github.com/Preetdudhat03/password_manager_app" className="text-gray-400 hover:text-white transition-colors" target="_blank" rel="noopener noreferrer">
                            GitHub
                        </Link>
                        <Link href="/disclaimer" className="text-gray-400 hover:text-white transition-colors">
                            Disclaimer
                        </Link>
                        <Link href="/backup-recovery" className="text-gray-400 hover:text-white transition-colors">
                            Recovery
                        </Link>
                    </div>
                </div>
            </div>
        </footer>
    );
}

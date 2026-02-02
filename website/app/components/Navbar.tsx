import Link from 'next/link';

export default function Navbar() {
    return (
        <nav className="w-full border-b border-white/10 bg-black/50 backdrop-blur-md sticky top-0 z-50">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="flex items-center justify-between h-16">
                    <div className="flex-shrink-0">
                        <Link href="/" className="text-xl font-bold tracking-tight text-white">
                            SecureVault
                        </Link>
                    </div>
                    <div className="hidden md:block">
                        <div className="ml-10 flex items-baseline space-x-4">
                            <Link href="/about" className="text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm font-medium transition-colors">
                                About
                            </Link>
                            <Link href="/how-it-works" className="text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm font-medium transition-colors">
                                How it Works
                            </Link>
                            <Link href="/security" className="text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm font-medium transition-colors">
                                Security
                            </Link>
                            <Link href="/architecture" className="text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm font-medium transition-colors">
                                Architecture
                            </Link>
                            <Link href="/download" className="bg-white text-black hover:bg-gray-200 px-4 py-2 rounded-md text-sm font-semibold transition-colors">
                                Download App
                            </Link>
                        </div>
                    </div>
                </div>
            </div>
        </nav>
    );
}

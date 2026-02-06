export const metadata = {
    title: "Architecture | Klypt",
    description: "High-level technical overview of Klypt.",
};

export default function ArchitecturePage() {
    return (
        <div className="max-w-4xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
            <h1 className="text-4xl font-bold tracking-tight mb-8 text-white">System Architecture</h1>

            <div className="grid md:grid-cols-2 gap-12">
                <div className="space-y-8">
                    <section>
                        <h2 className="text-2xl font-semibold mb-4 text-white">Frontend Framework</h2>
                        <p className="text-gray-400 leading-relaxed">
                            Klypt is built using Flutter, Google's UI toolkit for building natively compiled applications. This allows for high performance and strict control over memory management, which is crucial for handling sensitive data strings securely.
                        </p>
                    </section>

                    <section>
                        <h2 className="text-2xl font-semibold mb-4 text-white">Storage Engine</h2>
                        <p className="text-gray-400 leading-relaxed">
                            All data is persisted in a local-only database. Before any byte touches the disk, it is passed through an encryption layer. We use Hive for efficient key-value storage due to its speed and simplicity, wrapped in a custom encryption adapter.
                        </p>
                    </section>
                </div>

                <div className="space-y-8">
                    <section>
                        <h2 className="text-2xl font-semibold mb-4 text-white">Clean Architecture</h2>
                        <p className="text-gray-400 leading-relaxed">
                            The codebase follows Clean Architecture principles to separate concerns. The UI layer never speaks directly to the database. A Logic layer handles encryption, while a Data layer handles storage. This isolation ensures that even if a UI bug occurs, the core security logic remains intact.
                        </p>
                    </section>

                    <section>
                        <h2 className="text-2xl font-semibold mb-4 text-white">Platform Security</h2>
                        <p className="text-gray-400 leading-relaxed">
                            We leverage native Android security features, including the Keystore system for wrapping encryption keys and BiometricPrompt API for secure authentication. This ensures that your Master Key is protected by hardware-backed security where available.
                        </p>
                    </section>
                </div>
            </div>
        </div>
    );
}

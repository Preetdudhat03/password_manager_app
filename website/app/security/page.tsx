export const metadata = {
    title: "Security Model | Klypt",
    description: "Understanding Zero-Knowledge encryption and local-only security.",
};

export default function SecurityPage() {
    return (
        <div className="max-w-4xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
            <h1 className="text-4xl font-bold tracking-tight mb-8 text-white">Security Model</h1>

            <div className="space-y-12">
                <section>
                    <h2 className="text-2xl font-semibold mb-4 text-white">Zero-Knowledge Architecture</h2>
                    <p className="text-gray-400 leading-relaxed text-lg">
                        "Zero-Knowledge" means we know nothing about your data. We do not have servers. We do not have a database of users. We do not store your master password. If law enforcement served us a warrant for your data, we would have nothing to give them because we never possessed it in the first place.
                    </p>
                </section>

                <section>
                    <div className="grid md:grid-cols-2 gap-8">
                        <div className="p-6 bg-white/5 rounded-xl border border-white/10">
                            <h3 className="text-xl font-medium text-white mb-3">Encryption Standards</h3>
                            <p className="text-gray-400">
                                Your data is encrypted using industry-standard AES-256 encryption. The key to decrypt this data is derived from your Master Password, which is never stored in plain text.
                            </p>
                        </div>
                        <div className="p-6 bg-white/5 rounded-xl border border-white/10">
                            <h3 className="text-xl font-medium text-white mb-3">No Accounts Required</h3>
                            <p className="text-gray-400">
                                Since there is no server, there is no sign-up process. You don't verify an email or phone number. You simply install the app and start securing your secrets.
                            </p>
                        </div>
                    </div>
                </section>

                <section className="bg-red-500/10 border border-red-500/20 rounded-xl p-8">
                    <h2 className="text-2xl font-semibold mb-6 text-red-400">What this does NOT protect against</h2>
                    <ul className="space-y-4 text-gray-300">
                        <li className="flex items-start">
                            <span className="mr-3 text-red-500">✕</span>
                            <span><strong>Compromised Device:</strong> If your phone has malware that records keystrokes, your Master Password could be stolen when you type it.</span>
                        </li>
                        <li className="flex items-start">
                            <span className="mr-3 text-red-500">✕</span>
                            <span><strong>Physical coercion:</strong> If someone forces you to unlock your phone and app, the encryption cannot stop them from viewing the open vault.</span>
                        </li>
                        <li className="flex items-start">
                            <span className="mr-3 text-red-500">✕</span>
                            <span><strong>Data Loss:</strong> If you lose your phone and have no backup, your data is gone forever. We cannot restore it.</span>
                        </li>
                    </ul>
                </section>
            </div>
        </div>
    );
}

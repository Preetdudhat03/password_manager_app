import Link from "next/link";
import { Metadata } from "next";

export const metadata: Metadata = {
    title: "Security Model | Klypt",
    description: "Understanding Zero-Knowledge encryption, Argon2id key derivation, and local-only security.",
};

export default function SecurityPage() {
    return (
        <div className="max-w-4xl mx-auto px-4 py-16 sm:px-6 lg:px-8 text-gray-300">
            <div className="mb-12">
                <h1 className="text-4xl font-bold tracking-tight mb-4 text-white">Security Model</h1>
                <p className="text-xl text-gray-400">
                    Simple. Transparent. Local.
                </p>
            </div>

            <div className="space-y-16">
                {/* Core Philosophy */}
                <section>
                    <h2 className="text-2xl font-semibold mb-4 text-white">The Core Philosophy</h2>
                    <p className="leading-relaxed mb-4">
                        Klypt is built on a simple premise: <strong>If we don't have your data, we can't lose it, sell it, or give it away.</strong>
                    </p>
                    <p className="leading-relaxed">
                        Unlike cloud-based password managers that store your vault on central servers, Klypt keeps everything on your device. We are a zero-knowledge application, meaning the developer has absolutely no way to access your passwords, keys, or personal information.
                    </p>
                </section>

                {/* Technical Deep Dive */}
                <section>
                    <h2 className="text-2xl font-semibold mb-6 text-white">How We Encrypt Your Data</h2>
                    <div className="grid md:grid-cols-2 gap-6">
                        <div className="p-6 bg-white/5 rounded-xl border border-white/10">
                            <h3 className="text-lg font-medium text-white mb-2">Authenticated Encryption</h3>
                            <p className="text-sm text-gray-400 mb-4">
                                We use <strong>AES-256 GCM</strong> (Galois/Counter Mode).
                            </p>
                            <p className="text-sm">
                                This effectively puts your data in a digital safe. '256-bit' refers to the strength of the key, and 'GCM' ensures that not only is your data hidden, but it also hasn't been tampered with. If anyone tries to modify your encrypted file, it will fail to decrypt.
                            </p>
                        </div>

                        <div className="p-6 bg-white/5 rounded-xl border border-white/10">
                            <h3 className="text-lg font-medium text-white mb-2">Key Derivation</h3>
                            <p className="text-sm text-gray-400 mb-4">
                                We use <strong>Argon2id</strong>.
                            </p>
                            <p className="text-sm">
                                Your Master Password isn't just a key; it's the <i>source</i> of the key. We use Argon2id to transform your password into a cryptographic key. This process is deliberately slow and memory-hard, making it computationally expensive for attackers to guess your password using brute-force attacks.
                            </p>
                        </div>
                    </div>
                </section>

                {/* Biometrics */}
                <section>
                    <h2 className="text-2xl font-semibold mb-4 text-white">Biometric Security</h2>
                    <p className="leading-relaxed mb-4">
                        When you enable fingerprint or face unlock, we do not store your biometrics. Instead, we use the secure hardware on your device (Secure Enclave on iOS, Trusted Execution Environment on Android) to store a unique key that unlocks your vault.
                    </p>
                    <p className="leading-relaxed">
                        This cryptographic key is only released when the operating system confirms your identity. Klypt never sees or processes your actual fingerprint data.
                    </p>
                </section>

                {/* Threat Model */}
                <section className="bg-white/5 rounded-xl p-8 border border-white/10">
                    <h2 className="text-2xl font-semibold mb-6 text-white">Realistic Threat Model</h2>
                    <p className="mb-6">
                        Security is about trade-offs. We want you to understand exactly what Klypt protects you from, and what it cannot protect you from.
                    </p>

                    <div className="grid md:grid-cols-2 gap-8">
                        <div>
                            <h3 className="text-green-400 font-medium mb-4 flex items-center">
                                <span className="bg-green-400/10 p-1 rounded mr-2">✓</span> What Klypt Protects Against
                            </h3>
                            <ul className="space-y-3 text-sm">
                                <li className="flex items-start">
                                    <span className="mr-2 text-gray-500">•</span>
                                    <span><strong>Server Breaches:</strong> Since we have no servers, a hack on "Klypt HQ" would yield zero user data.</span>
                                </li>
                                <li className="flex items-start">
                                    <span className="mr-2 text-gray-500">•</span>
                                    <span><strong>Remote Mass Surveillance:</strong> Your data exists only on your device, decoupled from any central identity.</span>
                                </li>
                                <li className="flex items-start">
                                    <span className="mr-2 text-gray-500">•</span>
                                    <span><strong>Offline Attacks:</strong> If someone steals your encrypted backup, they would still need your Master Password (protected by Argon2id) to read it.</span>
                                </li>
                            </ul>
                        </div>

                        <div>
                            <h3 className="text-red-400 font-medium mb-4 flex items-center">
                                <span className="bg-red-400/10 p-1 rounded mr-2">✕</span> What YOU Must Protect Against
                            </h3>
                            <ul className="space-y-3 text-sm">
                                <li className="flex items-start">
                                    <span className="mr-2 text-gray-500">•</span>
                                    <span><strong>Device Malware:</strong> If your phone is infected with malware that records your screen or keystrokes, your Master Password could be compromised.</span>
                                </li>
                                <li className="flex items-start">
                                    <span className="mr-2 text-gray-500">•</span>
                                    <span><strong>Physical Coercion:</strong> Encryption cannot solve real-world threats where you are forced to unlock your device.</span>
                                </li>
                                <li className="flex items-start">
                                    <span className="mr-2 text-gray-500">•</span>
                                    <span><strong>Forgetting Your Password:</strong> We are a zero-knowledge system. If you forget your Master Password and lose your recovery phrase, <strong>we cannot recover your data</strong>.</span>
                                </li>
                            </ul>
                        </div>
                    </div>
                </section>

                {/* Open Source */}
                <section>
                    <h2 className="text-2xl font-semibold mb-4 text-white">Don't Trust Us. Trust the Code.</h2>
                    <p className="leading-relaxed">
                        Security through obscurity is not security. Klypt is an open-source project. This means security researchers and developers can audit our code to verify that we are doing exactly what we say we are.
                    </p>
                    <div className="mt-6">
                        <Link
                            href="https://github.com/Preetdudhat03/password_manager_app"
                            className="text-blue-400 hover:text-blue-300 transition-colors inline-flex items-center"
                            target="_blank"
                        >
                            View Source Code on GitHub
                            <svg className="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" /></svg>
                        </Link>
                    </div>
                </section>
            </div>
        </div>
    );
}

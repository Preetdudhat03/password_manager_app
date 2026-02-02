export const metadata = {
    title: "How It Works | SecureVault",
    description: "A simple guide to how SecureVault protects your passwords.",
};

export default function HowItWorksPage() {
    return (
        <div className="max-w-4xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
            <h1 className="text-4xl font-bold tracking-tight mb-8 text-white">How It Works</h1>

            <div className="space-y-12">
                <section>
                    <p className="text-gray-400 leading-relaxed text-lg mb-8">
                        SecureVault is designed to be simple and predictable. Here is the lifecycle of your data:
                    </p>

                    <div className="relative border-l border-gray-800 ml-3 space-y-10">
                        <div className="pl-8 relative">
                            <span className="absolute -left-1.5 top-1.5 h-3 w-3 rounded-full bg-blue-500 ring-4 ring-black"></span>
                            <h3 className="text-xl font-medium text-white mb-2">1. You Create a Master Key</h3>
                            <p className="text-gray-400">
                                When you first open the app, you create a Master Password. Think of this as the only key to a physical safe. We do not (and cannot) see this password.
                            </p>
                        </div>

                        <div className="pl-8 relative">
                            <span className="absolute -left-1.5 top-1.5 h-3 w-3 rounded-full bg-blue-500 ring-4 ring-black"></span>
                            <h3 className="text-xl font-medium text-white mb-2">2. Data is Locked Instantly</h3>
                            <p className="text-gray-400">
                                Every time you add a password, the app actively mixes it up (encrypts it) using your Master Key before saving it to your phone's storage. It's like shredding a document and keeping the only reassembly guide in your head.
                            </p>
                        </div>

                        <div className="pl-8 relative">
                            <span className="absolute -left-1.5 top-1.5 h-3 w-3 rounded-full bg-blue-500 ring-4 ring-black"></span>
                            <h3 className="text-xl font-medium text-white mb-2">3. Nothing Leaves Your Phone</h3>
                            <p className="text-gray-400">
                                SecureVault has no internet connection code. Your encrypted data sits quietly on your device. It is never sent to a cloud server, ensuring that a server breach elsewhere cannot compromise you.
                            </p>
                        </div>

                        <div className="pl-8 relative">
                            <span className="absolute -left-1.5 top-1.5 h-3 w-3 rounded-full bg-blue-500 ring-4 ring-black"></span>
                            <h3 className="text-xl font-medium text-white mb-2">4. Access with Biometrics</h3>
                            <p className="text-gray-400">
                                For convenience, you can use your fingerprint or face unlock to open the vault. This uses the secure hardware on your phone to provide the Master Key without you typing it every time.
                            </p>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    );
}

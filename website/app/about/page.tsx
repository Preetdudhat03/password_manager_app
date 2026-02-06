export const metadata = {
    title: "About | Klypt",
    description: "Learn why we built Klypt as an offline-only password manager.",
};

export default function AboutPage() {
    return (
        <div className="max-w-4xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
            <h1 className="text-4xl font-bold tracking-tight mb-8 text-white">About Klypt</h1>

            <div className="space-y-12">
                <section>
                    <h2 className="text-2xl font-semibold mb-4 text-white">What is a Password Manager?</h2>
                    <p className="text-gray-400 leading-relaxed text-lg">
                        A password manager is a secure vault for your digital keys. Instead of remembering dozens of passwords, you only need to remember one master password. It manages the complexity of generating, storing, and retrieving your credentials safely.
                    </p>
                </section>

                <section>
                    <h2 className="text-2xl font-semibold mb-4 text-white">Why Klypt?</h2>
                    <p className="text-gray-400 leading-relaxed text-lg">
                        We built Klypt to explore the intersection of usability and absolute privacy. Most commercial password managers rely on cloud synchronization, which introduces a remote attack vector. Klypt takes a different approach: <strong>your data never leaves your device.</strong>
                    </p>
                </section>

                <section>
                    <h2 className="text-2xl font-semibold mb-4 text-white">Why Offline?</h2>
                    <p className="text-gray-400 leading-relaxed text-lg">
                        By removing network access entirely, we eliminate an entire class of security threats. There is no server to hack, no API to exploit, and no "man-in-the-middle" attacks. Your encrypted database resides solely on your phone's storage.
                    </p>
                </section>

                <section>
                    <h2 className="text-2xl font-semibold mb-4 text-white">The "Micro Project" Philosophy</h2>
                    <p className="text-gray-400 leading-relaxed text-lg">
                        Klypt is intentionally designed as a micro project. It is not a startup product trying to scale to millions of users. It is an engineering exercise in building a robust, focused utility. This allows us to prioritize transparency and simplicity over feature bloat.
                    </p>
                </section>
            </div>
        </div>
    );
}

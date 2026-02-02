export const metadata = {
    title: "Disclaimer | SecureVault",
    description: "Important legal and safety disclaimer.",
};

export default function DisclaimerPage() {
    return (
        <div className="max-w-3xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
            <h1 className="text-4xl font-bold tracking-tight mb-8 text-white">Disclaimer</h1>

            <div className="prose prose-invert prose-lg text-gray-400">
                <p className="font-semibold text-white">
                    Please read this disclaimer carefully before using the SecureVault application.
                </p>

                <h3 className="text-white">Educational Purpose</h3>
                <p>
                    SecureVault was created as a <strong>micro project</strong> for educational and portfolio purposes. While it implements industry-standard encryption (AES-256) and security best practices, it has <strong>not</strong> undergone a third-party security audit.
                </p>

                <h3 className="text-white">No Warranty</h3>
                <p>
                    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
                </p>

                <h3 className="text-white">Use at Your Own Risk</h3>
                <p>
                    By downloading and using this application, you acknowledge that you are doing so at your own risk. The developer (Preet Dudhat) is not liable for any data loss, damages, or security breaches that may occur.
                </p>

                <h3 className="text-white">Not for High-Risk Use</h3>
                <p>
                    We do not recommend using this application for storing highly critical information such as banking credentials, crypto private keys, or national identity documents unless you have personally verified the source code and understand the risks.
                </p>
            </div>
        </div>
    );
}

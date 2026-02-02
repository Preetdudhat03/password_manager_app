export const metadata = {
    title: "Backup & Recovery | SecureVault",
    description: "Critical information about data recovery and backups.",
};

export default function BackupRecoveryPage() {
    return (
        <div className="max-w-4xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
            <h1 className="text-4xl font-bold tracking-tight mb-8 text-white">Backup & Recovery</h1>

            <div className="space-y-12">
                <section className="bg-amber-500/10 border border-amber-500/20 rounded-xl p-8">
                    <div className="flex items-start gap-4">
                        <span className="text-4xl">⚠️</span>
                        <div>
                            <h2 className="text-xl font-bold text-amber-500 mb-2">CRITICAL WARNING</h2>
                            <p className="text-amber-200/80 leading-relaxed">
                                If you lose your phone and have not manually exported a backup, <strong>your passwords cannot be recovered.</strong> There is no "Forgot Password" button. There is no customer support team that can unlock your account.
                            </p>
                        </div>
                    </div>
                </section>

                <section>
                    <h2 className="text-2xl font-semibold mb-4 text-white">Why No Password Reset?</h2>
                    <p className="text-gray-400 leading-relaxed text-lg mb-6">
                        To have a "reset password" feature, a company must have a way to bypass your original password. This creates a "backdoor" that hackers or governments could also use. We chose security over convenience. only YOU hold the keys.
                    </p>
                </section>

                <section>
                    <h2 className="text-2xl font-semibold mb-4 text-white">How to Backup</h2>
                    <div className="prose prose-invert text-gray-400">
                        <ol className="list-decimal pl-5 space-y-2">
                            <li>Open SecureVault Settings.</li>
                            <li>Select <strong>Export Encrypted Backup</strong>.</li>
                            <li>Save the resulting file to a safe location (e.g., a USB drive, Google Drive, or your PC).</li>
                            <li>This file is strictly encrypted. It can only be imported back into SecureVault using the original Master Password.</li>
                        </ol>
                    </div>
                </section>
            </div>
        </div>
    );
}

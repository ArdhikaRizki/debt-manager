import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import 'feedback_controller.dart';

class FeedbackView extends GetView<FeedbackController> {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saran & Kesan TPM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Silakan masukkan saran dan kesan Anda untuk mata kuliah Teknologi Pemrograman Mobile (TPM). Data ini disimpan secara lokal.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // SARAN FIELD
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller.saranController,
                  maxLines: 4,
                  maxLength: FeedbackController.maxCharsPerField,
                  decoration: InputDecoration(
                    labelText: 'Saran',
                    labelStyle: TextStyle(
                      color: controller.saranError.value.isEmpty 
                        ? Colors.grey 
                        : Colors.red,
                    ),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: controller.saranError.value.isEmpty 
                          ? Colors.grey.shade300 
                          : Colors.red,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: controller.saranError.value.isEmpty 
                          ? Colors.blue 
                          : Colors.red,
                        width: 2,
                      ),
                    ),
                    helperText: controller.saranError.value.isNotEmpty 
                      ? controller.saranError.value 
                      : null,
                    helperStyle: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
                if (controller.saranCharCount.value > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${controller.saranCharCount.value}/${FeedbackController.maxCharsPerField}',
                      style: TextStyle(
                        fontSize: 12,
                        color: controller.saranCharCount.value > FeedbackController.maxCharsPerField 
                          ? Colors.red 
                          : Colors.grey,
                      ),
                    ),
                  ),
              ],
            )),
            const SizedBox(height: 16),
            // KESAN FIELD
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller.kesanController,
                  maxLines: 4,
                  maxLength: FeedbackController.maxCharsPerField,
                  decoration: InputDecoration(
                    labelText: 'Kesan',
                    labelStyle: TextStyle(
                      color: controller.kesanError.value.isEmpty 
                        ? Colors.grey 
                        : Colors.red,
                    ),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: controller.kesanError.value.isEmpty 
                          ? Colors.grey.shade300 
                          : Colors.red,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: controller.kesanError.value.isEmpty 
                          ? Colors.blue 
                          : Colors.red,
                        width: 2,
                      ),
                    ),
                    helperText: controller.kesanError.value.isNotEmpty 
                      ? controller.kesanError.value 
                      : null,
                    helperStyle: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
                if (controller.kesanCharCount.value > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${controller.kesanCharCount.value}/${FeedbackController.maxCharsPerField}',
                      style: TextStyle(
                        fontSize: 12,
                        color: controller.kesanCharCount.value > FeedbackController.maxCharsPerField 
                          ? Colors.red 
                          : Colors.grey,
                      ),
                    ),
                  ),
              ],
            )),
            const SizedBox(height: 16),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.saveFeedback(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: controller.isLoading.value 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Simpan Feedback', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )),
            const SizedBox(height: 24),
            const Divider(),
            const Text('Riwayat Saran & Kesan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.feedbacks.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (controller.feedbacks.isEmpty) {
                  return const Center(child: Text('Belum ada feedback tersimpan.'));
                }

                return ListView.builder(
                  itemCount: controller.feedbacks.length,
                  itemBuilder: (context, index) {
                    final item = controller.feedbacks[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(item['created_at'] as int);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Saran:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            Text(item['saran']),
                            const SizedBox(height: 8),
                            const Text('Kesan:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(item['kesan']),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

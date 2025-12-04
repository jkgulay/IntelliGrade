<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div v-if="isVisible" class="feedback-overlay" @click.self="dismissSurvey">
        <div class="feedback-modal">
          <!-- Header -->
          <div class="feedback-header">
            <div class="header-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                <path
                  d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"
                />
              </svg>
            </div>
            <h3>How was your experience?</h3>
            <p>Help us improve IntelliGrade by sharing your feedback</p>
          </div>

          <!-- Survey Content -->
          <div class="feedback-content">
            <!-- Overall Satisfaction -->
            <div class="feedback-section">
              <label class="section-label">Overall Experience</label>
              <div class="rating-stars">
                <button
                  v-for="star in 5"
                  :key="star"
                  :class="['star-btn', { active: rating >= star }]"
                  @click="rating = star"
                >
                  <svg
                    width="28"
                    height="28"
                    viewBox="0 0 24 24"
                    :fill="rating >= star ? '#fbbf24' : 'none'"
                    :stroke="rating >= star ? '#fbbf24' : '#d1d5db'"
                    stroke-width="2"
                  >
                    <path
                      d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"
                    />
                  </svg>
                </button>
              </div>
              <div class="rating-labels">
                <span>Poor</span>
                <span>Excellent</span>
              </div>
            </div>

            <!-- Question Categories -->
            <div class="feedback-section">
              <label class="section-label">What did you like? (Select all that apply)</label>
              <div class="checkbox-grid">
                <label v-for="option in likeOptions" :key="option.value" class="checkbox-item">
                  <input type="checkbox" v-model="selectedLikes" :value="option.value" />
                  <span class="checkbox-label">{{ option.label }}</span>
                </label>
              </div>
            </div>

            <!-- Improvement Areas -->
            <div class="feedback-section">
              <label class="section-label">What could be improved?</label>
              <div class="checkbox-grid">
                <label v-for="option in improveOptions" :key="option.value" class="checkbox-item">
                  <input type="checkbox" v-model="selectedImprovements" :value="option.value" />
                  <span class="checkbox-label">{{ option.label }}</span>
                </label>
              </div>
            </div>

            <!-- Additional Comments -->
            <div class="feedback-section">
              <label class="section-label">Additional Comments (Optional)</label>
              <textarea
                v-model="comments"
                placeholder="Share your thoughts, suggestions, or report any issues..."
                rows="3"
                class="feedback-textarea"
              ></textarea>
            </div>
          </div>

          <!-- Actions -->
          <div class="feedback-actions">
            <button class="btn-skip" @click="dismissSurvey">Maybe Later</button>
            <button class="btn-submit" @click="submitFeedback" :disabled="!rating || isSubmitting">
              <span v-if="isSubmitting" class="submit-spinner"></span>
              <span v-else>Submit Feedback</span>
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script lang="ts">
import { ref, watch } from 'vue'
import { supabase } from '@/supabase'

export default {
  name: 'FeedbackSurvey',
  props: {
    show: {
      type: Boolean,
      default: false,
    },
    context: {
      type: String,
      default: 'quiz_completion', // quiz_completion, grading, general
    },
    contextId: {
      type: String,
      default: null,
    },
    userId: {
      type: String,
      required: true,
    },
    userType: {
      type: String,
      default: 'student', // student or teacher
    },
  },
  emits: ['close', 'submitted'],
  setup(props, { emit }) {
    const isVisible = ref(false)
    const isSubmitting = ref(false)
    const rating = ref(0)
    const comments = ref('')
    const selectedLikes = ref([])
    const selectedImprovements = ref([])

    const likeOptions = [
      { value: 'auto_grading', label: '⚡ Fast auto-grading' },
      { value: 'clear_feedback', label: '📝 Clear feedback' },
      { value: 'easy_navigation', label: '🧭 Easy navigation' },
      { value: 'accurate_scoring', label: '✅ Accurate scoring' },
      { value: 'helpful_analytics', label: '📊 Helpful analytics' },
      { value: 'time_saving', label: '⏰ Time saving' },
    ]

    const improveOptions = [
      { value: 'loading_speed', label: '🚀 Loading speed' },
      { value: 'more_feedback', label: '💬 More detailed feedback' },
      { value: 'ui_design', label: '🎨 Interface design' },
      { value: 'question_variety', label: '📋 Question variety' },
      { value: 'mobile_experience', label: '📱 Mobile experience' },
      { value: 'instructions', label: '📖 Better instructions' },
    ]

    watch(
      () => props.show,
      (newVal) => {
        isVisible.value = newVal
      },
    )

    const dismissSurvey = () => {
      isVisible.value = false
      emit('close')
    }

    const submitFeedback = async () => {
      if (!rating.value || isSubmitting.value) return

      isSubmitting.value = true

      try {
        // Create feedback record
        const feedbackData = {
          user_id: props.userId,
          user_type: props.userType,
          context: props.context,
          context_id: props.contextId,
          rating: rating.value,
          likes: selectedLikes.value,
          improvements: selectedImprovements.value,
          comments: comments.value || null,
          submitted_at: new Date().toISOString(),
        }

        const { error } = await supabase.from('user_feedback').insert([feedbackData])

        if (error) {
          // If table doesn't exist, log but don't crash
          console.warn('Feedback submission warning:', error.message)
        }

        console.log('Feedback submitted:', feedbackData)

        emit('submitted', feedbackData)
        dismissSurvey()
      } catch (error) {
        console.error('Error submitting feedback:', error)
      } finally {
        isSubmitting.value = false
      }
    }

    return {
      isVisible,
      isSubmitting,
      rating,
      comments,
      selectedLikes,
      selectedImprovements,
      likeOptions,
      improveOptions,
      dismissSurvey,
      submitFeedback,
    }
  },
}
</script>

<style scoped>
.feedback-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: 1rem;
}

.feedback-modal {
  background: white;
  border-radius: 16px;
  width: 100%;
  max-width: 480px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.feedback-header {
  background: linear-gradient(135deg, #3d8d7a, #2d6a5a);
  color: white;
  padding: 1.5rem;
  text-align: center;
}

.header-icon {
  width: 48px;
  height: 48px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1rem;
}

.feedback-header h3 {
  font-size: 1.25rem;
  font-weight: 600;
  margin: 0 0 0.5rem;
}

.feedback-header p {
  font-size: 0.875rem;
  opacity: 0.9;
  margin: 0;
}

.feedback-content {
  padding: 1.5rem;
}

.feedback-section {
  margin-bottom: 1.5rem;
}

.feedback-section:last-child {
  margin-bottom: 0;
}

.section-label {
  display: block;
  font-size: 0.875rem;
  font-weight: 600;
  color: #374151;
  margin-bottom: 0.75rem;
}

/* Rating Stars */
.rating-stars {
  display: flex;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.star-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.25rem;
  transition: transform 0.2s;
}

.star-btn:hover {
  transform: scale(1.15);
}

.star-btn.active svg {
  filter: drop-shadow(0 0 6px rgba(251, 191, 36, 0.5));
}

.rating-labels {
  display: flex;
  justify-content: space-between;
  font-size: 0.75rem;
  color: #9ca3af;
  padding: 0 0.5rem;
}

/* Checkbox Grid */
.checkbox-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.5rem;
}

.checkbox-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  background: #f9fafb;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid transparent;
}

.checkbox-item:hover {
  background: #f0fdf4;
  border-color: #3d8d7a;
}

.checkbox-item input[type='checkbox'] {
  width: 16px;
  height: 16px;
  accent-color: #3d8d7a;
}

.checkbox-label {
  font-size: 0.8rem;
  color: #374151;
}

/* Textarea */
.feedback-textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  font-size: 0.875rem;
  resize: vertical;
  font-family: inherit;
  transition: border-color 0.2s;
}

.feedback-textarea:focus {
  outline: none;
  border-color: #3d8d7a;
  box-shadow: 0 0 0 3px rgba(61, 141, 122, 0.1);
}

/* Actions */
.feedback-actions {
  display: flex;
  gap: 0.75rem;
  padding: 1rem 1.5rem 1.5rem;
  background: #f9fafb;
  border-top: 1px solid #e5e7eb;
}

.btn-skip {
  flex: 1;
  padding: 0.75rem 1rem;
  background: transparent;
  color: #6b7280;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-skip:hover {
  background: #f3f4f6;
  color: #374151;
}

.btn-submit {
  flex: 1;
  padding: 0.75rem 1rem;
  background: linear-gradient(135deg, #3d8d7a, #2d6a5a);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.btn-submit:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(61, 141, 122, 0.3);
}

.btn-submit:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

.submit-spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

/* Modal Transition */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

/* Dark mode support */
.dark .feedback-modal {
  background: #1f2937;
}

.dark .section-label {
  color: #e5e7eb;
}

.dark .checkbox-item {
  background: #374151;
}

.dark .checkbox-item:hover {
  background: #1e3a32;
}

.dark .checkbox-label {
  color: #e5e7eb;
}

.dark .feedback-textarea {
  background: #374151;
  border-color: #4b5563;
  color: #e5e7eb;
}

.dark .feedback-actions {
  background: #111827;
  border-color: #374151;
}

/* Responsive */
@media (max-width: 480px) {
  .checkbox-grid {
    grid-template-columns: 1fr;
  }
}
</style>

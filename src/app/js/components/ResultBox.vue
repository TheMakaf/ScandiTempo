<template>
    <div class="result-box">
        <button class="copy button is-warning tooltipped tooltipped-n" data-clipboard-target=".result-box" aria-label="Copied!">Copy</button>
        <div v-if="isInLoadingState">
            <grid-loader :loading="true" :color="'rgb(93, 197, 150)'" :size="'50px'"></grid-loader>
        </div>
        <div v-else>
            <p>Hello team,</p>
            <p class="section-heading">Summary of critical issues:</p>
            <p>n/a</p>
            <p class="section-heading done-today">Done today:</p>
            <div class="ticket" v-if="doneToday.length > 0" v-for="(ticket, index) in doneToday" :key="index">
                <p>
                    <span class="bold">{{ index + 1 }}. - {{ ticket.issue.name }} - </span>
                    <span>{{ ticket.issue.summary }} (<a :href="getIssueLink(ticket)" target="_blank">{{ getIssueLink(ticket) }}</a>) - </span>
                    <span>{{ transformToHours(ticket.timeSpentSeconds) }}h</span>
                </p>
                <p class="ticket-comment">{{ formatDescription(ticket.description) }}</p>
            </div>
            <div class="ticket" v-if="doneToday.length < 1">
                <p>n/a</p>
            </div>
            <p class="section-heading">Exceeded estimate:</p>
            <p>n/a</p>
            <p class="section-heading">Pending tasks:</p>
                <div class="ticket">
                    <p class="pending" v-if="pendingTasks.length > 0" v-for="(ticket, index) in pendingTasks" :key="index">
                        <span class="bold">{{ index + 1 }}. - {{ ticket.key }} - </span>
                        <span>{{ ticket.fields.summary }} (<a :href="getIssueLink(ticket)">{{ getIssueLink(ticket) }}</a>)</span>
                    </p>
                    <p v-if="pendingTasks.length === 0">n/a</p>
                </div>
            <p class="section-heading">Input from PM / Client Required:</p>
            <p>n/a</p>
            <p class="summary">
                <span>Total time spent: {{ totalTimeSpent }}h</span><br/>
                <span>Approximate amount of pending tasks in hours: {{ approxPendingTaskHours }}h</span>
            </p>
            <p>Best regards,</p>
        </div>
    </div>
</template>
<script>
import GridLoader from 'vue-spinner/src/GridLoader'
import ClipboardJS from 'clipboard'

export default {
    mounted() {
        const clip = new ClipboardJS('.copy');
        clip.on('success', (e) => {
            e.clearSelection();
        });
    },
    computed: {
        isInLoadingState() {
            return this.$store.state.loading;
        },
        doneToday() {
            return this.$store.state.reportData.doneToday;
        },
        pendingTasks() {
            return this.$store.state.reportData.pendingTasks;
        },
        totalTimeSpent() {
            return this.transformToHours(this.$store.state.reportData.doneToday.reduce(this.computeTotal, 0));
        },
        approxPendingTaskHours() {
            const pendingIssues = this.$store.state.reportData.pendingTasks;
            let totalApproxHours = 0;

            pendingIssues.forEach((ticket) => {
                const {
                    originalEstimateSeconds: estimateSeconds,
                    timeSpentSeconds,
                    remainingEstimateSeconds
                } = ticket.fields.timetracking;

                if (remainingEstimateSeconds) {
                    totalApproxHours += remainingEstimateSeconds;
                } else if (estimateSeconds && timeSpentSeconds) {
                    if (estimateSeconds > timeSpentSeconds) {
                        totalApproxHours += Math.abs(estimateSeconds - timeSpentSeconds);
                    }
                } else if (estimateSeconds && timeSpentSeconds === undefined) {
                    totalApproxHours += estimateSeconds;
                }
            });

            if (totalApproxHours > 0) {
                return this.transformToHours(totalApproxHours);
            }

            return totalApproxHours;
        }
    },
    methods: {
        transformToHours(timeInSeconds) {
            return (timeInSeconds / 60 / 60).toFixed(2);
        },
        computeTotal(accumulator, ticket) {
            return accumulator + ticket.timeSpentSeconds;
        },
        getIssueLink(ticket) {
            return `${ticket.issue.self.split('/').splice(0, 3).join('/')}/browse/${ticket.issue.key}`;
        },
        formatDescription(description) {
            // TODO: Format list with "-" if it is not formatted
            return description;
        },
    },
    components: {
        GridLoader
    }
}
</script>

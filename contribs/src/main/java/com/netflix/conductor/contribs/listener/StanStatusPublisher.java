/**
 * Copyright 2016 Netflix, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 *
 */
package com.netflix.conductor.contribs.listener;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.netflix.conductor.common.run.Workflow;
import com.netflix.conductor.common.run.WorkflowSummary;
import com.netflix.conductor.core.config.Configuration;
import com.netflix.conductor.core.events.EventQueues;
import com.netflix.conductor.core.events.queue.Message;
import com.netflix.conductor.core.events.queue.ObservableQueue;
import com.netflix.conductor.core.execution.WorkflowStatusListener;
import com.netflix.conductor.core.orchestration.ExecutionDAOFacade;
import com.netflix.conductor.dao.QueueDAO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Inject;
import java.util.List;

/**
 * Publishes a @see Message containing a @see WorkflowSummary to a DynoQueue on
 * a workflow completion or termination event.
 */
public class StanStatusPublisher implements WorkflowStatusListener {

    private static final Logger LOGGER = LoggerFactory.getLogger(StanStatusPublisher.class);
    private final ObjectMapper objectMapper;
    private final String successStatusQueue;
    private final String failureStatusQueue;
    private final EventQueues eventQueues;
    private final ExecutionDAOFacade executionDAOFacade;
    private final Boolean archiveWorkflow;

    @Inject
    public StanStatusPublisher(QueueDAO queueDAO, ObjectMapper objectMapper, Configuration config,
            EventQueues eventQueues, ExecutionDAOFacade executionDAOFacade) {
        this.objectMapper = objectMapper;
        this.eventQueues = eventQueues;

        this.successStatusQueue = config.getProperty("workflowstatuslistener.publisher.success.queue", "");
        this.failureStatusQueue = config.getProperty("workflowstatuslistener.publisher.failure.queue", "");
        this.archiveWorkflow = config.getBoolProperty("workflowstatuslistener.workflow.archive", false);
        this.executionDAOFacade = executionDAOFacade;
    }

    @Override
    public void onWorkflowCompleted(Workflow workflow) {
        LOGGER.info("Publishing callback of workflow {} on completion topic {} ", workflow.getWorkflowId(),
                this.successStatusQueue);

        workflowListener(this.successStatusQueue, workflow);
    }

    @Override
    public void onWorkflowTerminated(Workflow workflow) {
        LOGGER.info("Publishing callback of workflow {} on termination topic {}", workflow.getWorkflowId(),
                this.failureStatusQueue);

        workflowListener(this.failureStatusQueue, workflow);
    }

    private void workflowListener(String topic, Workflow workflow) {
        // if topic was defined -> send message
        if (topic != "") {
            ObservableQueue queue = eventQueues.getQueue(topic);
            List<Message> messages = new java.util.ArrayList<Message>();
            messages.add(workflowToMessage(workflow));
            queue.publish(messages);
        }

        archiveWorkflow(workflow.getWorkflowId());
    }

    private void archiveWorkflow(String workflowId) {
        if (archiveWorkflow) {
            LOGGER.info("Archive workflow {} ", workflowId);
            executionDAOFacade.removeWorkflow(workflowId, true);
        }
    }

    private Message workflowToMessage(Workflow workflow) {
        String jsonWfSummary;
        WorkflowSummary summary = new WorkflowSummary(workflow);
        try {
            jsonWfSummary = objectMapper.writeValueAsString(summary);
        } catch (JsonProcessingException e) {
            LOGGER.error("Failed to convert WorkflowSummary: {} to String. Exception: {}", summary, e);
            throw new RuntimeException(e);
        }
        return new Message(workflow.getWorkflowId(), jsonWfSummary, null);
    }
}

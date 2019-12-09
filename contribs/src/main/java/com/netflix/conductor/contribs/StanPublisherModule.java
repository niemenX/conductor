package com.netflix.conductor.contribs;

import com.google.inject.AbstractModule;
import com.netflix.conductor.contribs.listener.StanStatusPublisher;
import com.netflix.conductor.core.execution.WorkflowStatusListener;

public class StanPublisherModule extends AbstractModule {
    
    @Override
    protected void configure() {
        bind(WorkflowStatusListener.class).to(StanStatusPublisher.class);
    }
}

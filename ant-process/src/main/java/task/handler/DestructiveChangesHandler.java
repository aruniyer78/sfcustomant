/*
 * Daimler CRM - Extension Platform
 */
package task.handler;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.io.output.FileWriterWithEncoding;
import org.apache.commons.lang3.StringUtils;
import org.apache.tools.ant.BuildException;

import task.handler.DestructiveChangesHandler.DestructiveChange.MODE;

/**
 * DestructiveChangesHandler
 *
 * @author  XLEHMF
 */
public class DestructiveChangesHandler
{

  public static class DestructiveChange
  {

    public static enum MODE
    {
      PRE, POST, BOTH
    }

    private MODE mode;
    private String type;
    private String fullName;
    private String timestamp;

    public DestructiveChange(MODE mode, String type, String fullName, String timestamp)
    {
      this.mode = mode;
      this.type = type;
      this.fullName = fullName;
      this.timestamp = timestamp;
    }

    public String getTimestamp()
    {
      return timestamp;
    }

    public void setTimestamp(String timestamp)
    {
      this.timestamp = timestamp;
    }

    public MODE getMode()
    {
      return mode;
    }

    public String getType()
    {
      return type;
    }

    public String getFullName()
    {
      return fullName;
    }

  }

  private final static Set<String> SUPPORTED_TYPES = new HashSet<>(Arrays.asList(new String[]{
      "ApprovalProcess",
      "EscalationRules,EscalationRule",
      "AssignmentRules",
      "AssignmentRule",
      "CustomObjectSharingRules",
      "CustomObjectOwnerSharingRule",
      "CustomObjectCriteriaBasedSharingRule",
      "CampaignSharingRules",
      "CampaignCriteriaBasedSharingRule",
      "CampaignOwnerSharingRule",
      "CaseSharingRules",
      "CaseOwnerSharingRule",
      "CaseCriteriaBasedSharingRule",
      "AccountSharingRules",
      "AccountCriteriaBasedSharingRule",
      "AccountOwnerSharingRule",
      "Workflow",
      "WorkflowRule",
      "WorkflowOutboundMessage",
      "WorkflowFieldUpdate",
      "WorkflowAlert",
      "WorkflowTask",
      "WorkflowKnowledgePublish",
      "WorkflowSend",
      "Layout",
      "QuickAction",
      "CustomApplication",
      "CustomTab",
      "RemoteSiteSetting",
      "ApexTrigger",
      "ApexPage",
      "ApexComponent",
      "ApexClass",
      "Profile",
      "Role",
      "ExternalDataSource",
      "CustomLabels",
      "CustomLabel",
      "ReportType",
      "CustomObjectTranslation",
      "CustomObject",
      "CustomField",
      "BusinessProcess",
      "WebLink",
      "ValidationRule",
      "SharingReason",
      "ListView",
      "FieldSet",
      "Translations",
      "HomePageLayout",
      "HomePageComponent",
      "CustomPageWebLink",
      "Report",
      "RecordType",
      "Flow",
      "Dashboard",
      "Queue",
      "AutoResponseRules",
      "AutoResponseRule",
      "EmailTemplate",
      "Settings",
      "CustomPermission",
      "Network",
      "CallCenter",
      "DataCategoryGroup",
      "PermissionSet",
      "CustomApplicationComponent",
      "Group",
      "SynonymDictionary",
      "SamlSsoConfig",
      "Portal",
      "Letterhead",
      "AppMenu",
      "Document",
      "StaticResource",
      "Community" }));

  private LogWrapper logWrapper;
  private String destructiveRoot;
  private String destructiveFile;

  @SuppressWarnings("hiding")
  public void initialize(LogWrapper logWrapper, String destructiveRoot, String destructiveFile)
  {
    this.logWrapper = logWrapper;
    this.destructiveRoot = destructiveRoot;
    this.destructiveFile = destructiveFile;

    validate();
  }

  private void validate()
  {
    if (null == logWrapper) {
      throw new BuildException("DestructiveChangesHandler (logWrapper) not properly initialized.");
    }
    if (null == destructiveRoot) {
      throw new BuildException("DestructiveChangesHandler (destructiveRoot) not properly initialized.");
    }
    if (null == destructiveFile) {
      throw new BuildException("DestructiveChangesHandler (destructiveFile) not properly initialized.");
    }
  }

  public List<DestructiveChange> readDestructiveChanges(MODE modeFilter)
  {
    List<DestructiveChange> result = new ArrayList<>();

    File file = new File(destructiveRoot, destructiveFile);

    try (FileInputStream fis = new FileInputStream(file);
        InputStreamReader isr = new InputStreamReader(fis, "UTF-8");
        BufferedReader br = new BufferedReader(isr)) {
      String line = null;
      do {
        line = br.readLine();
        if (StringUtils.isNotEmpty(line)) {
          String trimmed = line.trim();
          if (!StringUtils.startsWith(trimmed, "#")) {
            String[] tokens = trimmed.split(":");
            if ((3 > tokens.length) || (4 < tokens.length)) {
              throw new BuildException(String.format("Error reading destructive changes. File format error. The format is <mode>:<type>:<name>[:<code>]."));
            }
            if (MODE.BOTH.equals(modeFilter) || modeFilter.name().equals(tokens[0].toUpperCase())) {
              MODE mode = null;
              try {
                mode = MODE.valueOf(StringUtils.upperCase(tokens[0]));
              } catch (IllegalArgumentException | NullPointerException e) {
                throw new BuildException("The mode must be either 'pre' or 'post'.");
              }
              String timestamp = (4 == tokens.length) ? tokens[3] : null;
              String type = tokens[1];
              if (!SUPPORTED_TYPES.contains(type)) {
                throw new BuildException(String.format("Unsupported type for destructive change: %s.", type));
              }
              result.add(new DestructiveChange(mode, type, tokens[2], timestamp));
            }
          }
        }
      }
      while (line != null);
    }
    catch (IOException e) {
      throw new BuildException(String.format("Error reading destructive changes: %s.", e.getMessage()), e);
    }

    return result;
  }

  public void writeDestructiveChanges(List<DestructiveChange> destructiveChanges)
  {
    File file = new File(destructiveRoot, destructiveFile);

    List<String> comments = new ArrayList<>();

    try (FileInputStream fis = new FileInputStream(file);
        InputStreamReader isr = new InputStreamReader(fis, "UTF-8");
        BufferedReader br = new BufferedReader(isr)) {
      String line = null;
      do {
        line = br.readLine();
        if (StringUtils.isNotEmpty(line)) {
          String trimmed = line.trim();
          if (StringUtils.startsWith(trimmed, "#")) {
            comments.add(trimmed);
          }
        }
      }
      while (line != null);
    }
    catch (IOException e) {
      throw new BuildException(String.format("Error reading destructive changes: %s.", e.getMessage()), e);
    }

    try (FileWriterWithEncoding fw = new FileWriterWithEncoding(file, "UTF-8");
        BufferedWriter bw = new BufferedWriter(fw)) {
      for (String line : comments) {
        bw.write(line);
        bw.newLine();
      }
      for (DestructiveChange destructiveChange : destructiveChanges) {
        if (null != destructiveChange.getTimestamp()) {
          bw.write(String.format("%s:%s:%s:%s",
                                 destructiveChange.getMode().name().toLowerCase(),
                                 destructiveChange.getType(),
                                 destructiveChange.getFullName(),
                                 destructiveChange.getTimestamp()));
        }
        else {
          bw.write(String.format("%s:%s:%s",
                                 destructiveChange.getMode().name().toLowerCase(),
                                 destructiveChange.getType(),
                                 destructiveChange.getFullName()));
        }
        bw.newLine();
      }
    }
    catch (IOException e) {
      throw new BuildException(String.format("Error writing destructive changes: %s.", e.getMessage()), e);
    }
  }

}
